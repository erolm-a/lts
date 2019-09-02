#include <fstream>
#include <iostream>
#include <vector>
#include <cstring>
#include <tuple>
#include <unordered_map>

using namespace std;

struct State;
struct JointAction;
struct Valuations;

static int graphviz_id_counter = 0;

vector<string> split(const string& str, char separator);

// parse a State. A state has the format
// [0-9]+;...
// For example 001;010
struct State {
    string state;
    State(const string& str);
    State() = default;
    int getID() const;
    string getVisualString() const {
        string translated;

        for(auto ch: state)
            if(ch == ';')
                translated += "\\n";
            else
                translated += ch;
        return translated;
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

    JointAction(const string& str): actions{split(str, ';')} {}
    JointAction() = default;
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
};

using edge = tuple<State, JointAction, Valuations>;

struct Statehash {
    size_t operator()(const State& s) const;
};

static unordered_map<State, vector<edge>, Statehash> adj_list;
static unordered_map<State, int, Statehash> graphviz_ids;

State::State(const string& str) :state{str} {
    if (graphviz_ids.find(*this) == graphviz_ids.end())
        graphviz_ids[*this] = graphviz_id_counter++;
}

int State::getID() const {
    return graphviz_ids[*this];
}

ostream& operator<<(ostream& o, const State&s) {
    return o << "Node" << graphviz_ids[s.state];
}

ostream& operator<<(ostream& o, const JointAction &j) {
    for(size_t i = 0; i < j.actions.size(); i++) {
        o << j.actions[i];
        if (i < j.actions.size()-1)
            o << "\\n";
    }
    return o;
}

ostream& operator<<(ostream& o, const Valuations &vs) {
    for(size_t i = 0; i < vs.valuations.size(); i++) {
        o << vs.valuations[i].first << vs.valuations[i].second;
        if (i < vs.valuations.size()-1)
            o << "\\n";
    }
    return o;
}


size_t Statehash::operator()(const State& s) const {
    return hash<string>()(s.state);
}


// parse a single line
void parse(const string& line);
edge parse_vertex(const string& str);
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

    for (int i = splitted.size()-2; i >= 0; i--) {
        auto [current_state, actions, valuations] = parse_vertex(splitted[i]);
        adj_list[current_state].push_back({last_vertex, actions, valuations});
        last_vertex = move(current_state);
    }
}

edge parse_vertex(const string& str) {

    // final element is just a state
    auto splitted = split(str, ':');
    if (splitted.size() == 3)
        return {State(splitted[0]), JointAction(splitted[1]), Valuations(splitted[2])};
    else {
        return {State(splitted[0]), JointAction(), Valuations()};
    }
}

void generate_graph(ofstream& file) {
    file << "digraph G {" << endl;

    for (auto& [state, id]: graphviz_ids)
        file << state << " [label=\""<< state.getVisualString() << "\"]"<< endl;

    for(auto& [state, edges]: adj_list) {
        for(auto& edge: edges) {
            auto& [to_state, joint_action, valuations] = edge;
            file << state << " -> " << to_state;
            if(joint_action.actions.size())
                file << " [label=\"" << joint_action << "\\n" << valuations << "\"]";
            file << endl;
        }
    }
    file << '}';
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
