# What I've understood so far

- Argumentation Framework (AF) is a pair of a set of arguments (AR) and attacks.

- A set S is conflict-free if there are no pairs of arguments in S that attack each other

- An argument A is acceptable within S if for any attacks(B, A) there is a B' in S such that attacks(B', B) holds.

- S is admissible if it is conflict-free and every argument within A is acceptable.

- **IDEA: When a human mind tries to develop a reasonment what it does is developing an admissible set that makes every
  conclusion it reaches acceptable**

- A preferred extension is a maximal admissible set of AF (wrt set inclusion).

- Admissible sets can be constructed inductively. For example, if A be acceptable within S, then S' = S U A is admissible

- Admissible sets constitute a complete partial ordering wrt set inclusion.  That implies that the preferred extension always
  exist (i.e. the sequence of admissible sets has an upper bound)

## Stable extensions

- A set S is a stable extension if it is conflict free and "spartan" i.e. attacks everything not in S
 
- Can be proven that they can be constructed inductively by simply taking every argument that makes S conflict-free.

- As we cannot extend a stable extension anymore, it must be a preferred extension.

The idea is: a matching problem usually involves finding stable extensions.

## Fixpoints

We need to introduce skeptical semantics

- The characteristic function:
    - Maps subsets of ARs to subsets of ARs
    - F_AF(S) = {A | A is acceptable wrt S}

- Why? Given S for granted, we want to "expand" our knowledgebase with arguments that can be defended by the KB.

- In fact, it can be proven that S is always a subset of F(S) iff S is admissible.
 - Sketch: Every element in S is always acceptable within S by definition of admissibility.
   Besides, if S is conflict-free then F(S) is conflict-free. Suppose not, then there would exist a B
   in F(S) such that B attacks A, A in F(S), hence there is a B' that attacks B, but S was admissible!

- F is monotonic wrt set inclusion, so we can expand our knowledge safely

- The maximal we can reach is called **Grounded extension**
