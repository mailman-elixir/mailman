defmodule DataEncodingTest do
  use ExUnit.Case
  require IEx

  def testing_string do
    """
    Litwo! Ojczyzno moja! Ty jesteś jak zdrowie. 

    Ile cię stracił. Dziś piękność twą w domu i czuł, że teraz Napoleon, człek mądry a potem najwyższych krajowych zamieszków. Dobra, całe wesoło, lecz w zastępstwie gospodarza, gdy je posłyszał, znikał nagle taż chętka, nie będziesz przy jego poznać nie miał wielką, i rozprawiali, nieco wylotów kontusza nalał węgrzyna i swoją ważność zarazem poznaje. jak światłość miesiąca. Nucąc chwyciła suknie, biegła bardzo szybko, suwała się ramieniu. Przeprosiwszy go powitać. Dawno domu lasami i Obuchowicz Piotrowski, Obolewski, Rożycki, Janowicz, Mirzejewscy, Brochocki i kłopotach, i zdrowie. 

    Nazywał się nagle, stronnicy Sokół na Francuza. oj, ten Bonapart czarował, no, tak mędrsi fircykom oprzeć się Soplica. wszyscy za pierwszym na świecie jeśli nasza młodzie wyjeżdża za duszę jego upadkiem domy i w klasztorze. Ciszę przerywał ale powiedzieć nie był zacietrzewiony jak refektarz, z nowych gości. W końcu, stawiła przed młodzieżą o ten Bonapart figurka! Bez Suworowa to mówiąc, że serce mu przed ganek zajechał któryś z woźnym Protazym ze srebrnymi klamrami trzewiki peruka z których by to mówiąc, że serce niewinne ale nigdzie nie chciał, według nowej.
    """
  end

  def testing_string_quoted do
    """
    Litwo! Ojczyzno moja! Ty jeste=C5=9B jak zdrowie.=20

    Ile ci=C4=99 straci=C5=82. Dzi=C5=9B pi=C4=99kno=C5=9B=C4=87 tw=C4=85 w =
    domu i czu=C5=82, =C5=BCe teraz Napoleon, cz=C5=82ek m=C4=85dry a potem =
    najwy=C5=BCszych krajowych zamieszk=C3=B3w. Dobra, ca=C5=82e weso=C5=82o, =
    lecz w zast=C4=99pstwie gospodarza, gdy je pos=C5=82ysza=C5=82, znika=C5=82=
    nagle ta=C5=BC ch=C4=99tka, nie b=C4=99dziesz przy jego pozna=C4=87 nie =
    mia=C5=82 wielk=C4=85, i rozprawiali, nieco wylot=C3=B3w kontusza nala=C5=82=
    w=C4=99grzyna i swoj=C4=85 wa=C5=BCno=C5=9B=C4=87 zarazem poznaje. jak =
    =C5=9Bwiat=C5=82o=C5=9B=C4=87 miesi=C4=85ca. Nuc=C4=85c chwyci=C5=82a =
    suknie, bieg=C5=82a bardzo szybko, suwa=C5=82a si=C4=99 ramieniu. =
    Przeprosiwszy go powita=C4=87. Dawno domu lasami i Obuchowicz =
    Piotrowski, Obolewski, Ro=C5=BCycki, Janowicz, Mirzejewscy, Brochocki i =
    k=C5=82opotach, i zdrowie.=20

    Nazywa=C5=82 si=C4=99 nagle, stronnicy Sok=C3=B3=C5=82 na Francuza. oj, =
    ten Bonapart czarowa=C5=82, no, tak m=C4=99drsi fircykom oprze=C4=87 =
    si=C4=99 Soplica. wszyscy za pierwszym na =C5=9Bwiecie je=C5=9Bli nasza =
    m=C5=82odzie wyje=C5=BCd=C5=BCa za dusz=C4=99 jego upadkiem domy i w =
    klasztorze. Cisz=C4=99 przerywa=C5=82 ale powiedzie=C4=87 nie by=C5=82 =
    zacietrzewiony jak refektarz, z nowych go=C5=9Bci. W ko=C5=84cu, =
    stawi=C5=82a przed m=C5=82odzie=C5=BC=C4=85 o ten Bonapart figurka! Bez =
    Suworowa to m=C3=B3wi=C4=85c, =C5=BCe serce mu przed ganek zajecha=C5=82 =
    kt=C3=B3ry=C5=9B z wo=C5=BAnym Protazym ze srebrnymi klamrami trzewiki =
    peruka z kt=C3=B3rych by to m=C3=B3wi=C4=85c, =C5=BCe serce niewinne ale =
    nigdzie nie chcia=C5=82, wed=C5=82ug nowej.
    """
  end

  test "#quoted_from/1 replaces all bytes correctly" do
    assert DataEncoding.quoted_from("Just a test of Unicode ążśźć") == "Just a test of Unicode =C4=85=C5=BC=C5=9B=C5=BA=C4=87"
  end

  test "#align_quoted/1 returns properly aligned string" do
    assert DataEncoding.align_quoted("1234567890poiuytrewqasdfghjklzxcvbnm,./1234567890poiuytrewqasdfghjkl.,mnbvcxzaqwsxcderfvbgtyhnmjuik,.lop;/'[") == "1234567890poiuytrewqasdfghjklzxcvbnm,./1234567890poiuytrewqasdfghjkl.,mnbv=\ncxzaqwsxcderfvbgtyhnmjuik,.lop;/'["
  end

  test "#quotes_from/1 returns text with lines not longer than 76 characters" do
    Enum.each String.split(DataEncoding.quoted_from(testing_string), "\n"), fn(l) ->
      assert String.length(l) <= 76
    end
  end

  test "#quoted_from/1 replaces spaces and tabs at the end of the line properly" do
    assert DataEncoding.quoted_from("Lorem ipsum \ndolor sit amet\t\nYYyyyy") == "Lorem ipsum=20\ndolor sit amet=09\nYYyyyy"
  end

end
