Class Monad (M : Type -> Type) : Type :=
  { 
    pure : forall {A : Type}, A -> M A;
    bind : forall {A B : Type}, M A -> (A -> M B) -> M B;
  }.

Class CorrectMonad (M : Type -> Type) `(E : Monad M) :=
  { 
    monad_left_identity : 
      forall (A B : Type) 
             (f : A -> M B) 
             {a : A}, 
      bind (pure a) f = f a;
    
    monad_right_identity : 
      forall {A : Type} 
             {m : M A}, 
      bind m pure = m;
  
    monad_associativity : 
      forall {A B C : Type} 
             {f : A -> M B} 
             {g : B -> M C} 
             {m : M A}, 
      bind (bind m f) g = bind m (fun (a : A) => bind (f a) g);
  }.
  
Instance optionMonad : Monad option :=
  { 
    pure A x := Some x;
    
    bind A B ma f := 
      match ma with
        | None   => None
        | Some a => f a
      end;
  }.
  
Theorem option_monad_left_identity : forall (A B : Type) (f : A -> option B) (a : A), bind (pure a) f = f a.
Proof.
  intros A B f a.
  simpl.
  reflexivity.
Qed.

Theorem option_monad_right_identity : forall (A : Type) (m : option A), bind m pure = m.
Proof.
  intros A m.
  destruct m as [| a].
  - simpl. reflexivity.
  - simpl. reflexivity.
Qed.

Theorem option_monad_associativity : forall (A B C : Type) (f : A -> option B) (g : B -> option C)
    (m : option A), bind (bind m f) g = bind m (fun a : A => bind (f a) g).
Proof.
  intros A B C f g m.
  destruct m as [| a ].
  - simpl. reflexivity.
  - simpl. reflexivity.
Qed.
  
Instance correctOptionMonad : CorrectMonad option optionMonad :=
  { 
    monad_left_identity := option_monad_left_identity;
    monad_right_identity := option_monad_right_identity;
    monad_associativity := option_monad_associativity;
  }.
  
Definition kleisli (F : Type -> Type) (A B : Type) : Type := A -> F B.

Class Category (CAT : Type -> Type -> Type) : Type :=
  {
  
    id : forall {A : Type}, CAT A A;
  
    compose : forall {A B C : Type}, CAT B C -> CAT A B -> CAT A C;
  
  }.

Class CorrectCategory (CAT : Type -> Type -> Type) (E : Category CAT) : Type := 
  {
  
    category_left_identity : forall {A B : Type} {f : CAT A B}, compose f id = f;
    
    category_right_identity : forall {A B : Type} {f : CAT A B}, compose id f = f;

    category_associativity : forall {A B C D : Type} {f : CAT C D} {g : CAT B C} {h : CAT A B},
      compose f (compose g h) = compose (compose f g) h;
    
  }. 
 
Definition Fn (A B : Type) := A -> B.
 
Instance fnCategory : Category Fn :=
  { 
    
    id A := fun a => a;
    
    compose A B C f g := fun a => f (g a);
    
  }.

Theorem eta_expand : forall (A B : Type) (f : A -> B), f = fun a => f a.
Proof. intros. reflexivity. Qed.

Theorem fn_category_left_identity : forall (A B : Type) (f : Fn A B), compose f id = f.
Proof. intros. simpl. reflexivity. Qed.

Theorem fn_category_right_identity : forall (A B : Type) (f : Fn A B), compose id f = f.
Proof. intros. simpl. reflexivity. Qed.

Theorem fn_category_associativity : forall (A B C D : Type) (f : Fn C D) (g : Fn B C) (h : Fn A B),
  compose f (compose g h) = compose (compose f g) h.
Proof. intros. simpl. reflexivity. Qed.

Instance fnCorrectCategory : CorrectCategory Fn fnCategory :=
  {
  
    category_left_identity := fn_category_left_identity;
    category_right_identity := fn_category_right_identity;
    category_associativity := fn_category_associativity;
  
  }.

  
Instance kleisliCategory (M : Type -> Type) `(Monad M) : Category (kleisli M) :=
  {
  
    id A := pure;
    
    compose A B C f g := fun a => bind (g a) f;
    
  }.
  
  (*
  monad_left_identity : 
      forall (A B : Type) 
             (f : A -> M B) 
             {a : A}, 
      bind (pure a) f = f a;
  *)
  
Theorem kleisli_category_left_identity : forall {M : Type -> Type} `{Monad M} (A B : Type) (f : kleisli M A B), compose f id = f.
Proof.
  intros.
  symmetry.
  simpl.
  rewrite <- (monad_left_identity A B f).
  rewrite <- (fn_category_left_identity A (M B) f).
  simpl.
  
Instance kleisliCorrectCategory (M : Type -> Type) `(MM : Monad M) `(CM : CorrectMonad M) : CorrectCategory (kleisli M) (kleisliCategory M MM) :=
  {
    category_left_identity := 1;
    category_right_identity := 1;
    category_associativity := 1;
  }.
  
  
(* Theorem kleisli_category_left_identity : forall (M : Type -> Type) `(CorrectMonad M) (A B : Type) (f : kleisli M A B), compose f id = f.
Proof. 
  intros.
  destruct f.
  simpl.
Admitted. *)
  
(* TODO: The Monad/CorrectMonad might not be correct here *)

(*
Instance correctKleisliCategory (M : Type -> Type) `(E : Monad M) `(CE : CorrectMonad M) `(Category (kleisli M)) : CorrectCategory (kleisli M) (kleisliCategory M E) :=  
  {
    
    category_left_identity A B f := kleisli_category_left_identity M CE A B f;
    category_right_identity := 1;
    category_associativity := 1;
    
  }.
  
*)

(* TODO: 
    - Kleisi instance for both
*)
















