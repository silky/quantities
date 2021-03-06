module Quantities.FreeAbelianGroup

import Quantities.Power

%default total
%access public


%assert_total
private
mergeWithBy : (k -> k -> Ordering) -> (v -> v -> v) ->
              List (k, v) -> List (k, v) -> List (k, v)
mergeWithBy _ _ [] ys = ys
mergeWithBy _ _ xs [] = xs
mergeWithBy order combine ((k1, v1) :: xs) ((k2, v2) :: ys) with (order k1 k2)
  | LT = (k1, v1) :: mergeWithBy order combine xs ((k2, v2) :: ys)
  | GT = (k2, v2) :: mergeWithBy order combine ((k1, v1) :: xs) ys
  | EQ = (k1, combine v1 v2) :: mergeWithBy order combine xs ys

private
mergeWith : Ord k => (v -> v -> v) ->
            List (k, v) -> List (k, v) -> List (k, v)
mergeWith = mergeWithBy compare

private
filterValues : (v -> Bool) -> List (k, v) -> List (k, v)
filterValues p = filter (p . snd)

--private
mapValue : (v -> w) -> List (k, v) -> List (k, w)
mapValue f = map (\(k, v) => (k, f v))

data FreeAbGrp : Type -> Type where
  MkFreeAbGrp : {a : Type} -> (List (a, Integer)) -> FreeAbGrp a

--data FreeAbGrp a = MkFreeAbGrp (List (a, Integer))

mkFreeAbGrp : Ord a => List (a, Integer) -> FreeAbGrp a
mkFreeAbGrp = MkFreeAbGrp . filterValues (/= 0)
                          . foldr (\x => mergeWith (+) [x]) []

unit : FreeAbGrp a
unit = MkFreeAbGrp []

implicit
inject : a -> FreeAbGrp a
inject x = MkFreeAbGrp [(x, 1)]

instance [freeabgrppower] Power (FreeAbGrp a) where
  (^) _ 0 = unit
  (^) (MkFreeAbGrp xs) i = MkFreeAbGrp $ mapValue (i*) xs

instance Eq a => Eq (FreeAbGrp a) where
  (MkFreeAbGrp xs) == (MkFreeAbGrp ys) = xs == ys

instance Ord a => Ord (FreeAbGrp a) where
  compare (MkFreeAbGrp xs) (MkFreeAbGrp ys) = compare xs ys

instance Ord a => Semigroup (FreeAbGrp a) where
  (MkFreeAbGrp xs) <+> (MkFreeAbGrp ys) =
    MkFreeAbGrp $ filterValues (/= 0) $ mergeWith (+) xs ys

instance Ord a => Monoid (FreeAbGrp a) where
  neutral = unit

instance Ord a => Group (FreeAbGrp a) where
  inverse = flip ((^) @{freeabgrppower}) (-1)

instance Ord a => AbelianGroup (FreeAbGrp a) where

-- Lift a function A -> G to a group homomorphism between the freely generated
-- abelian group of A to the group G.
lift : (Group g, Power g) => (a -> g) -> FreeAbGrp a -> g
lift f (MkFreeAbGrp xs) = concatMap (\(x, i) => ((f x) ^ i)) xs

inject_lift_lem : (Group g, Power g) => (f : a -> g) -> (x : a) -> lift f (inject x) = f x
inject_lift_lem f x = believe_me ()

lift_power_lem : (Group g, Power g, Ord a) => (f : a -> g) -> (x : FreeAbGrp a) ->
                 (i : Integer) -> lift f (x ^ i) = lift f x ^ i
lift_power_lem f x i = believe_me ()

lift_mult_lem : (Ord a, Group g, Power g) => (f : a -> g) -> (x : FreeAbGrp a) ->
                (y : FreeAbGrp a) -> lift f (x <+> y) = lift f x <+> lift f y
lift_mult_lem f x y = believe_me ()

freeabgrppower_correct : (Ord a) => (x : FreeAbGrp a) -> (i : Integer) -> ((^) @{freeabgrppower}) x i = (^) x i
freeabgrppower_correct x i = believe_me ()

{-
instance VerifiedMonoid Quantity where
  monoidNeutralIsNeutralL l = ?neutralL --proof { compute; trivial; }
  monoidNeutralIsNeutralR r = ?neutralR --proof { compute; trivial; }
-}
