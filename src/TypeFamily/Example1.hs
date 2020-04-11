{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleContexts #-}
module TypeFamily.Example1 where

-- import Data.Tuple (swap)
--
-- -- https://www.schoolofhaskell.com/school/to-infinity-and-beyond/pick-of-the-week/type-families-and-pokemon
--
-- -- Language Extensionのwhat isではなくhow to useをpokemonで例示する。
-- -- 全てのpokemonはタイプを持ち、pokemonのアビリティはタイプに依存する。
-- -- haskellを利用してrestricted portion of the pokemon worldを表現する
-- --
-- -- 1. Pokemonはタイプを持つ。今回はFire, Water, Grassに限定する。
-- -- 2. 各タイプに3体ずつpokemonを考える.
-- --      Fire type  : Chrmander, Charmeleon, Charizard
-- --      Water type : Squirtle, Wartortle, Blastoise
-- --      Grass type : Bulbasaur, Ivysaur, Venusaur
-- -- 3. 各タイプはタイプ特有の技を持っている.
-- -- 　 movesであれば、Water type -> Water moves, Fire type -> Fire moves, Grass type -> Grass moves
-- -- 4. バトルの際、下記の関係が成り立つとする。
-- --      Fire pokemon は常に Grass Pokemonに勝ち、
-- --      Grass pokemon は常に Water Pokemonに勝ち
-- --      Water pokemon は常に Fire Pokemonに且つ。
-- -- 5. 常に勝者を決定的にするため、同じタイプのポケモン同士を戦わせることはないとする。
-- -- 6. 他の人は独自のpokemonを他のモジュールから追加できる。
-- --
--
-- -- * First Attempt
-- -- 最初はType ClasesやType familiesを使わずに、これらのruleを実装する。
-- -- まずタイプとdistinctive movesについてやる.
-- data Fire = Charmander | Charmeleon | Charizard deriving Show
-- data Water = Squirtle | Wartortle | Blastoise deriving Show
-- data Grass = Bulbasaur | Ivysaur | Venusaur deriving Show
--
-- data FireMove = Ember | FlameThrower | FireBlast deriving Show
-- data WaterMove = Bubble | WaterGun deriving Show
-- data GrassMove = VineWhip deriving Show
--
-- pickFireMove :: Fire -> FireMove
-- pickFireMove Charmander = Ember
-- pickFireMove Charmeleon = FlameThrower
-- pickFireMove Charizard = FireBlast
--
-- pickWaterMove :: Water -> WaterMove
-- pickWaterMove Squirtle = Bubble
-- pickWaterMove _ = WaterGun
--
-- pickGrassMove :: Grass -> GrassMove
-- pickGrassMove _ = VineWhip
--
-- -- つぎはこれを戦わせる
-- printBattle :: String -> String -> String -> String -> String -> IO ()
-- printBattle pokemonOne moveOne pokemonTwo moveTwo winner = do
--   putStrLn $ pokemonOne ++ " used " ++ moveOne
--   putStrLn $ pokemonTwo ++ " used " ++ moveTwo
--   putStrLn $ "Winner is: " ++ winner ++ "\n"
--
-- example2 :: IO ()
-- example2 = printBattle "Wator Pokemon" "Water Attack" "Fire Pokemon" "Fire Attack" "Water Pokemon"
--
-- -- タイプで決まるようにする
-- battleWaterVsFire :: Water -> Fire -> IO ()
-- battleWaterVsFire water fire = printBattle (show water) moveOne (show fire) moveTwo (show water)
--   where
--     moveOne = show $ pickWaterMove water
--     moveTwo = show $ pickFireMove fire
--
-- battleFireVsWater :: Fire -> Water -> IO ()
-- battleFireVsWater = flip battleWaterVsFire
--
-- battleGrassVsWater :: Grass -> Water -> IO ()
-- battleGrassVsWater grass water = printBattle (show grass) moveOne (show water) moveTwo (show grass)
--   where
--     moveOne = show $ pickGrassMove grass
--     moveTwo = show $ pickWaterMove water
--
-- battleWaterVsGrass :: Water -> Grass -> IO ()
-- battleWaterVsGrass = flip battleGrassVsWater
--
-- battleFireVsGrass :: Fire -> Grass -> IO ()
-- battleFireVsGrass fire grass = printBattle (show fire) moveOne (show grass) moveTwo (show fire)
--   where
--     moveOne = show $ pickFireMove fire
--     moveTwo = show $ pickGrassMove grass
--
-- battleGrassVsFire :: Grass -> Fire -> IO ()
-- battleGrassVsFire = flip battleFireVsGrass
--
-- battleExample :: IO ()
-- battleExample = do
--   battleWaterVsFire  Squirtle   Charmander
--   battleFireVsWater  Charmeleon Wartortle
--   battleGrassVsWater Bulbasaur  Blastoise
--   battleWaterVsGrass Wartortle  Ivysaur
--   battleFireVsGrass  Charmeleon Ivysaur
--   battleGrassVsFire  Venusaur   Charizard
--
-- -- Intruducing Type Classes
-- -- さて、このタイミングで例えば新たなポケモン、ElectricタイプのPicachuを追加したいとする。
-- -- すると、更に独自のbattleElectricVS(Grass|Fire|Water)関数の定義が必要になる。
-- -- こういうのは形式化しておくのが望ましい。つまり,
-- --
-- -- * pokemonは行動選択する関数(move,pick)を利用する。
-- -- * battleでは勝者を決定し結果を出力する。
-- --
-- -- これらを形式化するためにtype classを利用する。
-- --
-- --
-- -- 1. The Pokemon type class
-- -- 今回は、ポケモンのタイプとmoveの選択の二種類の情報が必要になる（parameterになる）ため、
-- -- MultiParamTypeClassesの言語拡張を利用する
-- -- これでpick系の関数の置き換えを図る
--
-- class (Show pokemon, Show move) => Pokemon pokemon move where
--   pickMove :: pokemon -> move
--
-- instance Pokemon Fire FireMove where
--   pickMove Charmander = Ember
--   pickMove Charmeleon = FlameThrower
--   pickMove Charizard  = FireBlast
--
-- instance Pokemon Water WaterMove where
--   pickMove Squirtle = Bubble
--   pickMove _        = WaterGun
--
-- instance Pokemon Grass GrassMove where
--   pickMove _ = VineWhip
--
-- -- type checkerがType Classのinstanceを探しに行く際に、どれを利用しているかを伝えるために、
-- -- 型明示を行っている。(明示がないと -> Pokemon Fire a whereまでしか特定できない)
-- -- 明示することで、これがPokemon Fire FireMove whereまで決定でき、パターンマッチで実行関数を選択できる
-- pickByTypeClass :: IO ()
-- pickByTypeClass = do
--   print (pickMove Charmander :: FireMove)
--   print (pickMove Blastoise  :: WaterMove)
--   print (pickMove Bulbasaur  :: GrassMove)
--
-- -- 2. The Battle Type Class
-- -- 次はbattle系の関数の置き換えを図る
-- -- これには別のmulti param type classを定義すればいい.
-- -- またその際の制約として、すでに上で定義したPokemonをつけてあげると、show、pickMoveが保証される。
-- -- (showはPokemon multi param type class定義時の制約のため)
--
-- -- Ex. 良くない例
-- --
-- -- class (Pokemon pokemon move, Pokemon foe foeMove) => Battle pokemon move foe foeMove where
-- --   battle :: pokemon -> foe -> IO ()
-- --   battle pokemon foe = printBattle (show pokemon) (show move) (show foe) (show foeMove) (show pokemon)
-- --     where
-- --       move = pickMove pokemon
-- --       foeMove = pickMove foe
-- --
-- -- instance Battle Water WaterMove Fire FireMove
-- --
-- -- errorExample :: IO ()
-- -- errorExample = battle Squirtle Charmander
-- --
-- -- これは方針としては正しいが、型検査でambiguousエラーになる
-- -- なぜなら、型検査がこれを Battle Water move0 Fire foeMove0 までしか特定できず、
-- -- move0 と foeMove0 が曖昧であるがゆえに起きてしまう。
-- -- これはつまり上述(pickMove)したように、型検査器に型情報をうまく渡すことができれば解決する。
-- --
-- -- さて、これを治すための一番チンパンな方法としては、
-- -- 今回はIO()で返しているのでこれに情報を渡せるようにしてあげればいい。
-- -- すなわち、IO (move, foeMove) として呼び出し時に型明示してあげる
-- -- また、定義時にflip定義するものがあるがその時はこの型も、IO (foeMove, move) にする必要がある。
-- -- Data.TupleにはTupleを反転させる swap :: (a, b) -> (b, a) があるのでこれを利用する
--
-- class (Pokemon pokemon move, Pokemon foe foeMove)
--   => Battle pokemon move foe foeMove where
--   battle :: pokemon -> foe -> IO (move, foeMove)
--   battle pokemon foe = do
--     printBattle (show pokemon) (show move) (show foe) (show foeMove) (show pokemon)
--     return (move, foeMove)
--    where
--     foeMove = pickMove foe
--     move = pickMove pokemon
--
-- instance Battle Water WaterMove Fire FireMove
-- instance Battle Fire FireMove Water WaterMove where
--   battle a b = fmap swap $ flip battle a b
--
-- instance Battle Grass GrassMove Water WaterMove
-- instance Battle Water WaterMove Grass GrassMove where
--   battle a b = fmap swap $ flip battle a b
--
-- instance Battle Fire FireMove Grass GrassMove
-- instance Battle Grass GrassMove Fire FireMove where
--   battle a b = fmap swap $ flip battle a b
--
-- battleByTypeClass :: IO ()
-- battleByTypeClass = do
--   battle Squirtle Charmander :: IO (WaterMove, FireMove)
--   battle Charmeleon Wartortle :: IO (FireMove, WaterMove)
--   battle Bulbasaur Blastoise :: IO (GrassMove, WaterMove)
--   battle Wartortle Ivysaur :: IO (WaterMove, GrassMove)
--   battle Charmeleon Ivysaur :: IO (FireMove, GrassMove)
--   battle Venusaur Charizard :: IO (GrassMove, FireMove)
--   putStrLn "Done Fighting"


-- -- Introducing Type Faimilies
-- --
-- -- さて、今の所このプログラムはかなりひどい。
-- -- 型注釈を取り回す必要があるの終わっている。
-- -- 確かに形式化とか反復性の削減など当初の目的を果たしたものの、大きな改善と言えるかというと微妙である。
-- --
-- -- ここで再度 Pokemon Type Class 宣言を考えてみると、これは実はひどい定義ができる。
-- -- すなわち、火タイプのポケモンが、水タイプの技を利用できるように定義が可能である。
-- -- これは複数変数としてポケモンのタイプと技のタイプを渡しており
-- -- 我々は意図的にそれらの間の関係性を理解しているが、type checkerは何も知らないからである。
-- -- 実際にこのような定義が可能だ。
--
-- -- instance Pokemon Fire WaterMove where
-- --   pickMove _ = Bubble
--
-- -- 水タイプの技Bubbleを使用する火タイプのポケモンを定義できてしまった。
-- -- これは。。。
-- --
-- -- ということでここから、type familyを議論していく。
-- -- これによりtype checkerに「火タイプのポケモンは火タイプの技を利用する」ということを教えてあげられる。
-- -- 言語拡張を追加しよう
--
-- -- さて、結論から行くとPokemon type classは次のようにな形になる。
--
-- -- class (Show a, Show (Move a)) => Pokemon a where
-- --   data Move a :: *
-- --   pickMove :: a -> Move a
--
-- -- 先の例とは違い、type classに取る引数が一つになっている。
-- -- ただ、定義内部にMoveという型が入ってきている。
-- -- このMoveはtype functionで、ある型を取り、使われるMoveを返り値として返却する関数である。
-- -- 今回の例では、FireMoveを利用する代わりに、Move Fireを利用し、結果としてFireMoveを得る、というものである。
-- --
-- -- 型制約を見るとそちらにも記述しており、これでFireMoveなどが保有していたShow型クラスインスタンス性を記述している。
-- -- ただしこれには別の言語拡張である、FlexibleContexts が必要になるため有効化しておく。
-- -- されこれを利用して再度定義してみよう。
--
-- class (Show pokemon, Show (Move pokemon)) => Pokemon pokemon where
--   data Move pokemon :: *
--   pickMove :: pokemon -> Move pokemon
--
-- data Fire = Charmander | Charmeleon | Charizard deriving Show
-- instance Pokemon Fire where
--   data Move Fire = Ember | FlameThrower | FireBlast deriving Show
--   pickMove Charmander = Ember
--   pickMove Charmeleon = FlameThrower
--   pickMove Charizard  = FireBlast
--
-- data Water = Squirtle | Wartortle | Blastoise deriving Show
-- instance Pokemon Water where
--   data Move Water = Bubble | WaterGun deriving Show
--   pickMove Squirtle = Bubble
--   pickMove _        = WaterGun
--
-- data Grass = Bulbasaur | Ivysaur | Venusaur deriving Show
-- instance Pokemon Grass where
--   data Move Grass = VineWhip deriving Show
--   pickMove _ = VineWhip
--
-- pickByTCTF :: IO ()
-- pickByTCTF = do
--   print $ pickMove Squirtle
--   print $ pickMove Charmander
--   print $ pickMove Ivysaur
--
-- -- きれいになったね。型注釈などもなく想定しているパターンマッチが行われていることがわかる。
-- -- これで Pokemon type class の定義はできたけど、次に Battle type class の方はどうしようか？
--
--
-- -- 3. The new Battle type class
-- -- 上記で定義したPokemon型クラスを利用して定義すると以下のように定義できる。
--
-- class (Pokemon pokemon, Pokemon foe) => Battle pokemon foe where
--   battle :: pokemon -> foe -> IO ()
--   battle pokemon foe = printBattle (show pokemon) (show move) (show foe) (show foeMove) (show pokemon)
--     where
--       foeMove = pickMove foe
--       move    = pickMove pokemon
--
-- printBattle :: String -> String -> String -> String -> String -> IO ()
-- printBattle pokemonOne moveOne pokemonTwo moveTwo winner = do
--   putStrLn $ pokemonOne ++ " used " ++ moveOne
--   putStrLn $ pokemonTwo ++ " used " ++ moveTwo
--   putStrLn $ "Winner is: " ++ winner ++ "\n"
--
-- -- 先の上の定義では, foeMove, moveの型曖昧性により、呼び出し時に型明示が必要だったが、
-- -- 今回はそもそもpickMoveにおいて、TypeFamilyにより方が決定している。
-- -- またその決定した型はShow型のインスタンスであることもわかっているため、
-- -- この例ではもはや一番最初の例のように純粋にpokemonを与えるだけで結果が返るようになっている。
-- --
-- -- さて他の定義も行って完成させてみる。
--
-- instance Battle Water Fire
-- instance Battle Fire Water where
--   battle = flip battle
--
-- instance Battle Grass Water
-- instance Battle Water Grass where
--   battle = flip battle
--
-- instance Battle Fire Grass
-- instance Battle Grass Fire where
--   battle = flip battle
--
-- battleByTCTF :: IO ()
-- battleByTCTF = do
--   battle Squirtle Charmander
--   battle Charmeleon Wartortle
--   battle Bulbasaur Blastoise
--   battle Wartortle Ivysaur
--   battle Charmeleon Ivysaur
--   battle Venusaur Charizard
--
-- -- Ok. いい感じですね。
-- -- まぁ本題としてはこんなところだが、追加の話として、これに帰納を付け加えることをやっていこう。
-- --
-- -- 今、例えば水タイプと火タイプのバトルインスタンスを、`Battle Water Fire`として定義していて、
-- -- その逆に関してはflipして定義しているよね。
-- -- つまり現状は、「第一引数のポケモンが必ず勝利する」ような定義になっている。
-- -- そして出力としてはこんな感じになっている。
-- --
-- -- Winner Pokemon move
-- -- Loser  Pokemon move
-- -- Winner pokemon Wins
-- --
-- -- これは「第一引数に負けるポケモンを与えた場合の挙動としても同じ」であり、
-- -- 最初に勝つのポケモンの技、次に負けるポケモンの技、最後に勝者の表示
-- -- になるわけである。
-- --
-- -- これを変更して、インスタンスとして与えられたときにどちらが勝つかマッチさせて、
-- -- 表示としては与えられたポケモンの順番に表示する（つまり上の例で、最初の一行にLoserの出力を得る）
-- -- ような実装に切り替えてみる。


-- 4. Associated Type Synonyms
-- 例えば、「２つのうちどちらか」を返すように決定する場合、一般的にEither a bが利用されるが、
-- 今回の要求はちょっと違っていて、Fire Waterでバトルした際には必ずWaterを返すような
-- type checkerがほしいわけである。
--
-- ここでBattle type classの中に新しい関数 winner を定義する。
-- この関数は同じ場所に定義のある battle と同じ順に引数（pokemon）を受け取り勝者を決定する。

-- class (Pokemon pokemon, Pokemon foe) => Battle pokemon foe where
--   battle :: pokemon -> foe -> IO ()
--   battle pokemon foe = printBattle (show pokemon) (show move) (show foe) (show foeMove) (show pokemon)
--     where
--       foeMove = pickMove foe
--       move    = pickMove pokemon
--   -- winner :: pokemon -> foe -> ??? -- Is it 'pokemon' or 'foe' ?
--
-- instance Battle Water Fire where
--   winner :: Water -> Fire -> Wwater
--   winner water _ = water -- Water is first type variable of the type class, namely: pokemon
--
-- instance Battle Fire Water where
--   winner :: Fire -> Water -> Water
--   winner _ water = water -- Water is second type variable of the type class, namely: foe

-- これだと定義できなくて、問題なのは結果として引数のどちらを返すかが自明でないことである。
-- 上記の例で行くと、Battle Water Fireは第一引数を、Battle Fire Waterは第荷引数を返す必要があり、
-- winner関数の型として直接表現できないという感じである。
--
-- 嬉しいことに、type familyにはassociated type synonymsがサポートされている。
-- Battle type classでは、Winner pokemon foo typeを定義して、
-- その型の決定をinstanceに委ねることができる。
-- この場合は単なる型エイリアスなので'data'ではなく'type'を利用する。
-- Winnerは型関数でそのkindが * -> * -> * になっていて、'pokemon', 'foo'をとって、
-- 結果どちらかを返すように定義する。
-- デフォルト定義もできるので、デフォルトは'pokemon'を返しておくようにすると
-- instance実装のいくらかを省略できるので良い。

-- さてフル実装を記述していく
class (Show pokemon, Show (Move pokemon)) => Pokemon pokemon where
  data Move pokemon :: *
  pickMove :: pokemon -> Move pokemon

data Fire = Charmander | Charmeleon | Charizard deriving Show
instance Pokemon Fire where
  data Move Fire = Ember | FlameThrower | FireBlast deriving Show
  pickMove Charmander = Ember
  pickMove Charmeleon = FlameThrower
  pickMove Charizard = FireBlast

data Water = Squirtle | Wartortle | Blastoise deriving Show
instance Pokemon Water where
  data Move Water = Bubble | WaterGun deriving Show
  pickMove Squirtle = Bubble
  pickMove _ = WaterGun

data Grass = Bulbasaur | Ivysaur | Venusaur deriving Show
instance Pokemon Grass where
  data Move Grass = VineWhip deriving Show
  pickMove _ = VineWhip

printBattle :: String -> String -> String -> String -> String -> IO ()
printBattle pokemonOne moveOne pokemonTwo moveTwo winner = do
  putStrLn $ pokemonOne ++ " used " ++ moveOne
  putStrLn $ pokemonTwo ++ " used " ++ moveTwo
  putStrLn $ "Winner is: " ++ winner ++ "\n"

-- これが改良したBattle type class
-- またwinnerを選択する関数pickWinnerの実装は各instanceにまかせており、
-- （default実装があるので、instance側で定義のないものは引数の１つ目に自動的に決まる）
-- その関数を利用して、battleの第五引数は計算されている。
-- 型制約にShow (Winner pokemon foe) が入ってきているのはshowできることを明示するため。
-- Winner pokemon foe は結果的にpokemonかfoeになるため、Show型のインスタンスになっている。
class (Show (Winner pokemon foe), Pokemon pokemon, Pokemon foe) => Battle pokemon foe where
  type Winner pokemon foe :: *       -- definition of type family for winner
  type Winner pokemon foe = pokemon  -- default implementation

  battle :: pokemon -> foe -> IO ()
  battle pokemon foe = printBattle (show pokemon) (show move) (show foe) (show foeMove) (show winner)
   where
    foeMove = pickMove foe
    move = pickMove pokemon
    winner = pickWinner pokemon foe

  pickWinner :: pokemon -> foe -> Winner pokemon foe

-- type Winner Water Fireの定義はいらない（default実装があるため）
instance Battle Water Fire where
  pickWinner pokemon foe = pokemon

instance Battle Fire Water where
  type Winner Fire Water = Water
  pickWinner = flip pickWinner

instance Battle Grass Water where
  pickWinner pokemon foe = pokemon

instance Battle Water Grass where
  type Winner Water Grass = Grass
  pickWinner = flip pickWinner

instance Battle Fire Grass where
  pickWinner pokemon foe = pokemon

instance Battle Grass Fire where
  type Winner Grass Fire = Fire
  pickWinner = flip pickWinner

finalExample :: IO ()
finalExample = do
  battle Squirtle Charmander
  battle Charmeleon Wartortle
  battle Bulbasaur Blastoise
  battle Wartortle Ivysaur
  battle Charmeleon Ivysaur
  battle Venusaur Charizard
