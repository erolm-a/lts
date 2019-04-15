/*
    This file is part of a research project.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

#include <algorithm>
#include <cassert>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <vector>

using namespace std;

struct LTSState;

using PropertySet = unordered_set<string>;
using InnerState = vector<PropertySet>;
using ActionBranch = unordered_map<string, LTSState*>;

struct LTSState {
    InnerState props; 
    ActionBranch edges;
    LTSState() = default;
    explicit LTSState(string serialized_states){
        istringstream agent_tokenizer(serialized_states);
        string property_serialized_list;
        while(getline(agent_tokenizer, property_serialized_list, ';')) {
            props.emplace_back();
            istringstream property_tokenizer(serialized_states);
            string property_token;
            while(getline(property_tokenizer, property_token, ',')) {
                props.back().insert(property_token);
            }
        }
    }
    bool operator==(const LTSState& other) const {
        return props == other.props;
    }
};

ostream& operator<<(ostream& out, const LTSState& other) {
    out << '{';
    for(const PropertySet& ps: other.props) {
        out << '(';
        for(const string& property: ps)
            out << property << ',';
        out << "),";
    }
    out << '}';

    return out;
}

vector<LTSState*> states;

int main(int argc, char** argv) {
    if(argc != 2){
        cerr << "Usage: " << argv[0] << " <tree.csv>" << endl;
        return 1;
    }

    ifstream input(argv[1]);

    // I should manage the errors, but I don't care
    //
    // manage every line
    string line;
    while(getline(input, line)) {
        //cout << line << endl;
        cout << "------------------\n";
        cout << "Beginning new line\n";
        cout << "------------------\n";
        bool is_action = false;
        LTSState *prev_state = nullptr;
        string prev_action;
        istringstream tokenizer(line); string token;
        // A state is a sequence of properties delimited by commas or semicolons.
        // The sequence is enclosed by double quotes.
        while(tokenizer.rdbuf()->in_avail()) {
            if(!is_action) {
                // discard first and last quotes
                tokenizer.ignore();
                getline(tokenizer, token, '"');
                // get rid of the following ','
                tokenizer.ignore();
                cout << "state: " << token << endl;
                LTSState *new_state = new LTSState(token), *found = nullptr;

                // search if the state already exists
                for(LTSState* state: states)
                    if(*state == *new_state)
                        found = state;

                if(!found) {
                    states.push_back(new_state);
                    found = states.back();
                }
                else
                    delete new_state;
                
                if(prev_state && prev_action != "")
                    prev_state->edges[prev_action] = found;

                prev_state = found;
            }
            else {
                getline(tokenizer, prev_action, ',');
                cout << "action: " << prev_action << endl;
            }
            is_action ^= true;
        }
    }

    cout << *states[0] << endl;
}

