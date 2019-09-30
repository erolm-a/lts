#include <algorithm>
#include <fstream>
#include <iostream>
#include <sstream>
#include <vector>
#include <cstring>
#include <tuple>
#include <unordered_map>
#include <unordered_set>

using namespace std;

struct State;
struct JointAction;
struct Valuations;

vector<string> split(const string& str, char separator);
string join(const vector<string>& splitted, string separator);

bool startswith(const string& full_string, const string& prefix);

// parse a State. A state has the format
// [0-9]+;...
// For example 001;010
struct State {
    string state;
    State(const string& str);
    State() = default;
    int getID() const;
    string render() const {
        return join(split(state, ';'), "\\n");
    }

    bool operator==(const State& other) const {
        return state == other.state;
    }
};


// parse a JointAction. A joint action has basically the same format
// of a State but allows an alphabet
// For example lifeHal+;freedomCarla-
struct JointAction {
    vector<string> actions;

    JointAction(const string& str);
    JointAction() = default;
    int getID() const;
    string render() const {
        vector<string> new_actions(actions.size());
        // filter out the "doNothing" actions and replace them with dashes
        transform(actions.begin(), actions.end(), new_actions.begin(), [](const string& s) {return startswith(s, "doNothing") ? "-" : s;});
        return join(new_actions, "/");
    }

    bool operator==(const JointAction& other) const {
        return actions == other.actions;
    }
};

// parse a Valuation. A Valuation has the format (in Regex):
// [A-Za-z]+(\+|-);...
struct Valuations {
    vector<pair<string, char>> valuations;
    
    Valuations(const string& str) {
        auto res = split(str, ';');
        for (auto s: res) {
            char ch = s.back();
            s.pop_back();
            valuations.push_back({s, ch});
        }
    }

    Valuations() = default;
    bool operator==(const Valuations& other) const {
        return valuations == other.valuations;
    }
};

template<typename T>
static T& get_from_global(const string& str) {
    static unordered_map<string, T> memo;

    if (memo.find(str) == memo.end()) {
        return memo.insert_or_assign(str, T(str)).first->second;
    }
    return memo[str];
}

#define get_state(str) get_from_global<State>(str)
#define get_joint(str) get_from_global<JointAction>(str)
#define get_valuations(str) get_from_global<Valuations>(str)


using edge = tuple<State, JointAction, Valuations>;

auto StateHash = [](const State& s) {return hash<string>()(s.state);};
auto JointActionHash = [](const JointAction& j) {return hash<string>()(j.render());};

static unordered_map<State, vector<edge>, decltype(StateHash)> adj_list(0, StateHash);
static unordered_map<State, int, decltype (StateHash)> graphviz_state_ids(0, StateHash);
static unordered_map<JointAction, int, decltype (JointActionHash)> graphviz_joint_ids(0, JointActionHash);

static int graphviz_node_counter = 0;
static int graphviz_joint_counter = 0;

State::State(const string& str) :state{str} {
    if (graphviz_state_ids.find(*this) == graphviz_state_ids.end())
        graphviz_state_ids[*this] = graphviz_node_counter++;
}

JointAction::JointAction(const string& str): actions{split(str, ';')} {
    if(graphviz_joint_ids.find(*this) == graphviz_joint_ids.end())
        graphviz_joint_ids[*this] = graphviz_joint_counter++;
}

int State::getID() const {
    return graphviz_state_ids[*this];
}

int JointAction::getID() const {
    return graphviz_joint_ids[*this];
}

ostream& operator<<(ostream& o, const State&s) {
    return o << "Node" << graphviz_state_ids[s.state];
}

ostream& operator<<(ostream& o, const JointAction &j) {
    return o << j.render();
}

ostream& operator<<(ostream& o, const Valuations &vs) {
    for(size_t i = 0; i < vs.valuations.size(); i++) {
        o << vs.valuations[i].first << vs.valuations[i].second;
        if (i < vs.valuations.size()-1)
            o << "\\n";
    }
    return o;
}

string get_style_for_joint(const JointAction& j) {
    switch(j.getID()) {
        case 0:
            return "solid";
        case 1:
            return "dashed";
        case 2:
            return "dotted";
        default:
            return "bold";
    }
}

ostream& operator<<(ostream&o, const tuple<State, JointAction, State, Valuations>& edge) {
    const auto& [state, joint_action, to_state, valuations] = edge;
    o << state << " -> " << to_state;
    if(joint_action.actions.size())
        o << " [label=\"" << joint_action << "\\n" << valuations << "\",style=" << get_style_for_joint(joint_action) << "]";
    return o;
}


// parse a single line
void parse(const string& line);
edge parse_vertex(const string& str);
void generate_row(ofstream& file, string row);
void generate_graph(ofstream& file);

int main(int argc, char** argv) {
    if(argc != 3) {
        cerr << "Usage: " << argv[0] << " <tree.csv> <tree.dot>" << endl;
        return 1;
    }

    auto tree_file = ifstream(argv[1]);
    string row;

    cout << "Reading from " << argv[1] << endl;
    while(tree_file >> row) {
        cout << row << endl;
        parse(row);
    }

    auto dot_file = ofstream(argv[2]);
    generate_graph(dot_file);
}

void parse(const string& line) {
    auto splitted = split(line, ',');
    auto last_vertex = get<0>(parse_vertex(splitted.back()));

    for (long i = splitted.size()-2; i >= 0; i--) {
        auto [current_state, actions, valuations] = parse_vertex(splitted[i]);
        auto edge = make_tuple(last_vertex, actions, valuations);
        auto& current_state_adjs = adj_list[current_state];
        if (find(current_state_adjs.begin(), current_state_adjs.end(), edge) == current_state_adjs.end())
            adj_list[current_state].push_back({last_vertex, actions, valuations});
        last_vertex = move(current_state);
    }
}

edge parse_vertex(const string& str) {

    // final element is just a state
    auto splitted = split(str, ':');
    if (splitted.size() == 3)
        return {get_state(splitted[0]), get_joint(splitted[1]), get_valuations(splitted[2])};
    else {
        return {get_state(splitted[0]), JointAction(), Valuations()};
    }
}

void generate_graph(ofstream& file) {
    file << "digraph G {" << endl;

    for (auto& [state, id]: graphviz_state_ids)
        file << state << " [label=\""<< state.render() << "\"]"<< endl;

    for(auto& [state, edges]: adj_list) {
        for(auto& edge: edges) {
            auto& [to_state, joint_action, valuations] = edge;
            file << tuple(state, joint_action, to_state, valuations) << endl;
        }
    }
    file << '}';
}

bool startswith(const string& a, const string& b) {
    if (a.size() < b.size())
        return false;
    for(auto a_it = a.begin(), b_it = b.begin(); b_it != b.end(); a_it++, b_it++)
        if (*a_it != *b_it)
            return false;
    return true;
}

vector<string> split(const string& str, char separator) {
    vector<string> result;
    size_t pos = 0, prev_pos = 0;

    if(str.size() == 0)
        return {};

    do {
        pos = str.find(separator, prev_pos);
        result.push_back(str.substr(prev_pos, pos - prev_pos));
        prev_pos = pos+1;
    } while (pos != string::npos);

    return result;
}

string join(const vector<string>& splitted, string separator) {
    stringstream o;
    if (splitted.size() == 0)
        return "";

    for(size_t i = 0; i < splitted.size(); i++) {
        o << splitted[i];
        if(i < splitted.size() - 1)
            o << separator;
    }
    return o.str();
}
