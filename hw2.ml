type ('nonterminal, 'terminal) parse_tree =
  | Node of 'nonterminal * ('nonterminal, 'terminal) parse_tree list
  | Leaf of 'terminal
type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal
  
let convert_grammar gram1 =
  let fromsymbolgetaltlist rulelist symbol  = 
    (*Symbol to list of rules, adapted from my hw1*)
    let ret = List.filter (fun tocompare -> symbol = fst tocompare) rulelist in
    List.map (fun el -> snd el) ret
  in

  let rules = snd gram1 in
  let starter = fst gram1 in 
  (starter, fromsymbolgetaltlist rules)

let rec parse_tree_leaves tree = 
  match tree with
  (*Base case*)
  | Leaf term -> [term] 
  (*Recursive case on nodes children*)
  | Node (x, recur) -> List.flatten (List.map parse_tree_leaves recur)

let make_matcher gram = 
  let rec listparser symbol productionfunction list acceptor fragment = 
    let rec rulematcher  rule  fragment = 
      let rec symbolmatch sym remainingsym=

        let handlenonterminal nonx =
          let newalternativelist = productionfunction nonx in 
          let new_acceptor = (fun fragment -> rulematcher  remainingsym  fragment) in 
          (*recursive case*)
          listparser nonx productionfunction newalternativelist new_acceptor fragment
        in

        let handleterminal tx = 
          if fragment = [] then 
            None 
          else
            let head = List.hd fragment in
            let tail = List.tl fragment in
          (*Recursive case *)
          if head = tx then 
            rulematcher remainingsym tail 
          else 
            None
        in 
        match sym with
        | (N x) -> handlenonterminal x
        | (T y) -> handleterminal y
      in 

      (*Base case: matched*)
      if rule = [] then acceptor fragment else
      
      (*Symbol handling logic *)
      let sym = List.hd rule in
      let remainingsym = List.tl rule in 
      symbolmatch sym remainingsym
    in 

    (*Base case: no rules to check*)
    if list = [] then None else
    let rule = List.hd list in
    let remainingrules = List.tl list in
    let rulematched = rulematcher  rule  fragment in
    (*Base case: accepter accepted*)
    if rulematched != None then rulematched 
    (*Recursive case: go to next rule in list *)
    else (listparser symbol productionfunction remainingrules acceptor fragment)
  in 
  let startsymbolaltlist = (snd gram) (fst gram) in
  
  (*Construct matcher function*)
  fun acceptor fragment -> listparser (fst gram) (snd gram) startsymbolaltlist acceptor fragment

let make_parser gram =
  let rec listparser symbol productionfunction list acceptor fragment tre =
    let rec rulematcher rule fragment tre =
      let buildnode s t = (Node(s,t)) in
      let addleaf t tx = (t@[Leaf tx]) in
      let rec symbolmatch sym remainingsym = 
        
        let handlenonterminal nonx =  
          let newalternativelist = productionfunction nonx in 
          let new_acceptor = (fun fragment m -> rulematcher  remainingsym fragment (tre@[m] )) in
          (*recursive case*)
          listparser nonx productionfunction newalternativelist new_acceptor fragment []
        in 

        let handleterminal tx = 
          if fragment = [] then
            None
          else
            let head = List.hd fragment in
            let tail = List.tl fragment in 
          (*Recursive case *)
          if head = tx then 
            rulematcher remainingsym tail (addleaf tre tx)
          else
            None
        in
        match sym with
        | (N x) -> handlenonterminal x
        | (T y) -> handleterminal y
      in 
  
      (*Base case: matched*)
      if rule = [] then acceptor fragment (buildnode symbol tre) else
  
      (*Symbol handling logic *)
      let sym = List.hd rule in 
      let remainingsym = List.tl rule in 
      symbolmatch sym remainingsym
    in 
  
    (*Base case: no rules to check*)
    if list = [] then None else
    let rule = List.hd list in 
    let remainingrules = List.tl list in 
    let rulematched = rulematcher rule fragment tre in
    (*Base case: acceptorer accepted*)
    if rulematched  != None then rulematched 
    (*Recursive case: go to next rule in list *)
    else (listparser symbol productionfunction remainingrules acceptor fragment tre)
  in  
  let startsymbolaltlist = (snd gram) (fst gram) in

  (*Construct parser function*)
  fun fragment -> listparser (fst gram) (snd gram) startsymbolaltlist (fun fragment tree -> if fragment = [] then Some tree else None) fragment []