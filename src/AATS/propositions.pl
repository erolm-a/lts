/*
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

    @author Enrico Trombetta

    
    The purpuose of this module is to define the propositions and their domain.
    To keep generation simple, the framework chooses exactly one value from
    each domain of each variable, in a specific order which is provided by
    the user for convenience.
*/

% A proposition is simply declared with the format:
% proposition(proposition_name, proposition_order) where proposition_order should start from 0
% In this example, we have 3 predicates.

proposition(hasInsulin, 0).
proposition(hasMoney, 1).
proposition(isAlive, 2).

% As they are predicates, we give them a binary encoding: 0 for false, 1 for true
domain(hasInsulin, [0, 1]).
domain(hasMoney, [0, 1]).
domain(isAlive, [0, 1]).


