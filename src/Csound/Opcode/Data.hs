-- | Data
module Csound.Opcode.Data (

    -----------------------------------------------------
    -- * Buffer and Function tables

    {-
    -- ** Writing To Tables
    tableiw, tablew, tabw_i, tabw, 
    -}

    -- ** Reading From Tables
    table, tablei, table3, tab_i, tab, 

    -----------------------------------------------------
    -- * Signal Input and Output,  Sample and Loop Playback, Soundfonts

    -- ** Signal Input And Output
    inch, outch,

    -- ** Sample Playback With Optional Looping
    flooper2, sndloop,

    -----------------------------------------------------
    -- *  File Input and Output

    -- ** Sound File Input
    soundin, diskin2, mp3in,

    -- ** Sound File Queries
    filelen, filesr, filenchnls, filepeak, filebit,

    -- ** Sound File Output
    fout,

    -- ** Non-Soundfile Input And Output

    -----------------------------------------------------
    -- * Converters of Data Types
    Nums,
    
    -- ** Rate conversions
    downsamp, upsamp, interp,
    
    -- ** Amplitude conversions
    ampdb, ampdbfs, dbamp, dbfsamp,

    -- ** Pitch conversions
    cpspch,

    -- ** Integer and fractional parts
    fracD, floorD, ceilD, intD, roundD,
    fracSig, floorSig, ceilSig, intSig, roundSig,
        
    -----------------------------------------------------
    -- * Printing and Strings

    -- ** Simple Printing
    printi, printk,

    -- ** Formatted Printing

    -- ** String Variables
    sprintf, sprintfk,

    -- ** String Manipulation And Conversion
    strcat, strcatk

) where

import Csound.Exp
import Csound.Exp.Wrapper
import Csound.LowLevel
import Csound.Exp.Numeric

-----------------------------------------------------
-- * Buffer and Function tables


{-
-- ** Writing To Tables

-- | This opcode operates on existing function tables, changing their contents. tablew is for writing 
-- at k- or at a-rates, with the table number being specified at init time. Using tablew with i-rate signal 
-- and index values is allowed, but the specified data will always be written to the function table at k-rate, 
-- not during the initialization pass. The valid combinations of variable types are shown by the first letter of the variable names. 
--
-- > tablew asig, andx, ifn [, ixmode] [, ixoff] [, iwgmode]
-- > tablew isig, indx, ifn [, ixmode] [, ixoff] [, iwgmode]
-- > tablew ksig, kndx, ifn [, ixmode] [, ixoff] [, iwgmode]
--
-- doc: <http://www.csounds.com/manual/html/tablew.html>
tablew :: Sig -> Sig -> Tab -> SE ()
tablew a1 a2 a3 = se_ $ opc3 "tablew" (map sign [a, k, i]) a1 a2 a3
    where sign t = (x, t:t:is 4)

-- | This opcode operates on existing function tables, changing their contents. tableiw is 
-- used when all inputs are init time variables or constants and you only want to run it at 
-- the initialization of the instrument. The valid combinations of variable types are shown by the first letter of the variable names.
--
-- > tableiw isig, indx, ifn [, ixmode] [, ixoff] [, iwgmode]
--
-- doc: <http://www.csounds.com/manual/html/tableiw.html>
tableiw :: D -> D -> Tab -> SE ()
tableiw a1 a2 a3 = se_ $ opc3 "tableiw" [(i, is 6)] a1 a2 a3

-- | Fast table opcodes. Faster than table and tablew because don't allow wrap-around 
-- and limit and don't check index validity. Have been implemented in order to provide 
-- fast access to arrays. Support non-power of two tables (can be generated by any GEN function by giving a negative length value).
--
-- > tabw ksig, kndx, ifn [,ixmode]
-- > tabw asig, andx, ifn [,ixmode]
--
-- doc: <http://www.csounds.com/manual/html/tab.html>
tabw :: Sig -> Sig -> Tab -> SE ()
tabw a1 a2 a3 = se_ $ opc3 "tabw" (map sign [a, k]) a1 a2 a3
    where sign t = (x, t:t:is 2)

-- | Fast table opcodes. Faster than table and tablew because don't allow wrap-around 
-- and limit and don't check index validity. Have been implemented in order to provide 
-- fast access to arrays. Support non-power of two tables (can be generated by any GEN function by giving a negative length value).
--
-- > tabw_i isig, indx, ifn [,ixmode]
--
-- doc: <http://www.csounds.com/manual/html/tab.html>
tabw_i :: D -> D -> Tab -> SE ()
tabw_i a1 a2 a3 = se_ $ opc3 "tabw_i" [(x, is 4)] a1 a2 a3
-}

-- ** Reading From Tables

-- | Accesses table values by direct indexing. 
--
-- > ares table andx, ifn [, ixmode] [, ixoff] [, iwrap]
-- > ires table indx, ifn [, ixmode] [, ixoff] [, iwrap]
-- > kres table kndx, ifn [, ixmode] [, ixoff] [, iwrap]
--
-- doc: <http://www.csounds.com/manual/html/table.html>
table :: Sig -> Tab -> Sig

-- | Accesses table values by direct indexing with linear interpolation. 
--
-- > ares tablei andx, ifn [, ixmode] [, ixoff] [, iwrap]
-- > ires tablei indx, ifn [, ixmode] [, ixoff] [, iwrap]
-- > kres tablei kndx, ifn [, ixmode] [, ixoff] [, iwrap]
--
-- doc: <http://www.csounds.com/manual/html/tablei.html>
tablei :: Sig -> Tab -> Sig


-- | Accesses table values by direct indexing with cubic interpolation. 
--
-- > ares table3 andx, ifn [, ixmode] [, ixoff] [, iwrap]
-- > ires table3 indx, ifn [, ixmode] [, ixoff] [, iwrap]
-- > kres table3 kndx, ifn [, ixmode] [, ixoff] [, iwrap]
--
-- doc: <http://www.csounds.com/manual/html/table3.html>
table3 :: Sig -> Tab -> Sig

table = mkTable "table"
tablei = mkTable "tablei"
table3 = mkTable "table3"

mkTable :: Name -> Sig -> Tab -> Sig
mkTable name = opc2 name [
    (a, a:rest),
    (k, k:rest),
    (i, i:rest)]
    where rest = [i, i, i]

-- | Fast table opcodes. Faster than table and tablew because don't allow wrap-around 
-- and limit and don't check index validity. Have been implemented in order to provide 
-- fast access to arrays. Support non-power of two tables (can be generated by any GEN function by giving a negative length value).
--
-- > kr tab kndx, ifn[, ixmode]
-- > ar tab xndx, ifn[, ixmode]
--
-- doc: <http://www.csounds.com/manual/html/tab.html>
tab :: Sig -> Tab -> Sig
tab = opc2 "tab" [
    (a, [x,i,i]),
    (k, [k,i,i])]

-- | Fast table opcodes. Faster than table and tablew because don't allow wrap-around 
-- and limit and don't check index validity. Have been implemented in order to provide 
-- fast access to arrays. Support non-power of two tables (can be generated by any GEN function by giving a negative length value).
--
-- > ir tab_i indx, ifn[, ixmode]
--
-- doc: <http://www.csounds.com/manual/html/tab.html>
tab_i :: D -> Tab -> D
tab_i = opc2 "tab_i" [(i, [i,i,i])]

-- ** Saving Tables To Files

{-
-- ftsave "filename", iflag, ifn1 [, ifn2] [...]
ftsave :: S -> I -> [Tab] -> SE ()
ftsave a1 a2 a3 = opcs "ftsave" [(x, repeat i)] (phi a1 : phi a2 : map phi a3)
    where phi :: Val a => a -> E
          phi = Fix . unwrap  

-- ftsavek "filename", ktrig, iflag, ifn1 [, ifn2] [...]
ftsavek :: S -> Sig -> I -> [Tab] -> SE ()
ftsavek a1 a2 a3 a4 = opcs "ftsavek" [(x, repeat i)] (phi a1 : phi a2 : phi a3 : map phi a4)
    where phi :: Val a => a -> E
          phi = Fix . unwrap  
-}

-- ** Reading Tables From Files

-----------------------------------------------------
-- * Signal Input and Output,  Sample and Loop Playback, Soundfonts

-- ** Signal Input And Output

-- | Reads from numbered channels in an external audio signal or stream. 
--
-- > ain1[, ...] inch kchan1[,...]
--
-- doc: <http://www.csounds.com/manual/html/inch.html>
inch :: CsdTuple a => [Sig] -> a
inch = mopcs "inch" (repeat a, repeat k)

-- | Writes multi-channel audio data, with user-controllable channels, to an external device or stream. 
--
-- > outch kchan1, asig1 [, kchan2] [, asig2] [...]
--
-- doc: <http://www.csounds.com/manual/html/outch.html>
outch :: [(Sig, Sig)] -> SE ()
outch ts = se_ $ opcs "outch" [(x, cycle [a,k])] $ (\(a, b) -> [a, b]) =<< ts

-- ** Sample Playback With Optional Looping

-- | This opcode implements a crossfading looper with variable loop parameters and three 
-- looping modes, optionally using a table for its crossfade shape. It accepts non-power-of-two tables 
-- for its source sounds, such as deferred-allocation GEN01 tables.
--
-- > asig flooper2 kamp, kpitch, kloopstart, kloopend, kcrossfade, ifn \
-- >       [, istart, imode, ifenv, iskip]
--
-- doc: <http://www.csounds.com/manual/html/flooper2.html>
flooper2 :: Sig -> Sig -> Sig -> Sig -> Sig -> Tab -> Sig  
flooper2 = opc6 "flooper2" [(a, ks 5 ++ is 5)]

-- | This opcode records input audio and plays it back in a loop with user-defined duration and 
-- crossfade time. It also allows the pitch of the loop to be controlled, including reversed playback. 
--
-- > asig, krec sndloop ain, kpitch, ktrig, idur, ifad
--
-- doc: <http://www.csounds.com/manual/html/sndloop.html>
sndloop :: Sig -> Sig -> Sig -> D -> D -> (Sig, Sig)
sndloop = mopc5 "sndloop" ([a, k], [a,k,k,i,i])

-- ** Soundfonts And Fluid Opcodes

-----------------------------------------------------
-- *  File Input and Output

-- ** Sound File Input

-- | Reads audio data from an external device or stream. Up to 24 channels may be read before v5.14, extended to 40 in later versions. 
--
-- > ar1[, ar2[, ar3[, ... a24]]] soundin ifilcod [, iskptim] [, iformat] \
-- >      [, iskipinit] [, ibufsize]
--
-- doc: <http://www.csounds.com/manual/html/soundin.html>
soundin :: CsdTuple a => Str -> a
soundin = mopc1 "soundin" (repeat a, s:is 4)

-- | Reads audio data from a file, and can alter its pitch using one of several available interpolation 
-- types, as well as convert the sample rate to match the orchestra sr setting. diskin2 can also read 
-- multichannel files with any number of channels in the range 1 to 24 in versions before 5.14, and 
-- 40 after. . diskin2 allows more control and higher sound quality than diskin, but there is also the disadvantage of higher CPU usage.
--
-- > a1[, a2[, ... aN]] diskin2 ifilcod, kpitch[, iskiptim \
-- >       [, iwrap[, iformat [, iwsize[, ibufsize[, iskipinit]]]]]]
--
-- doc: <http://www.csounds.com/manual/html/diskin2.html>
diskin2 :: CsdTuple a => Str -> Sig -> a
diskin2 = mopc2 "diskin2" (repeat a, s:k:is 6)

-- | Reads stereo audio data from an external MP3 file. 
--
-- > ar1, ar2 mp3in ifilcod[, iskptim, iformat, iskipinit, ibufsize]
--
-- doc: <http://www.csounds.com/manual/html/mp3in.html>
mp3in :: Str -> (Sig, Sig)
mp3in = mopc1 "mp3in" ([a,a], s:is 4)


-- ** Sound File Queries

-- | Returns the length of a sound file. 
--
-- > ir filelen ifilcod, [iallowraw]
--
-- doc: <http://www.csounds.com/manual/html/filelen.html>
filelen :: Str -> D
filelen = opc1 "filelen" [(i, [i,i])]

-- | Returns the sample rate of a sound file. 
--
-- > ir filesr ifilcod [, iallowraw]
--
-- doc: <http://www.csounds.com/manual/html/filesr.html>
filesr :: Str -> D
filesr = opc1 "filesr" [(i, [i,i])]

-- | Returns the number of channels in a sound file.
--
-- > ir filenchnls ifilcod [, iallowraw]
--
-- doc: <http://www.csounds.com/manual/html/filechnls.html>
filenchnls :: Str -> D
filenchnls = opc1 "filenchnls" [(i, [i,i])]

-- | Returns the peak absolute value of a sound file. 
--
-- > ir filepeak ifilcod [, ichnl]
--
-- doc: <http://www.csounds.com/manual/html/filepeak.html>
filepeak :: Str -> D
filepeak = opc1 "filepeak" [(i, [i,i])]

-- | Returns the number of bits in each sample in a sound file.
--
-- > ir filebit ifilcod [, iallowraw]
--
-- doc: <http://www.csounds.com/manual/html/filebit.html>
filebit :: Str -> D
filebit = opc1 "filebit" [(i, [i,i])] 

-- ** Sound File Output

-- | fout outputs N a-rate signals to a specified file of N channels. 
--
-- > fout ifilename, iformat, aout1 [, aout2, aout3,...,aoutN]
--
-- doc: <http://www.csounds.com/manual/html/fout.html>
fout :: [Sig] -> SE ()
fout as = se_ $ opcs "fout" [(x, repeat a)] as

-- ** Non-Soundfile Input And Output

-----------------------------------------------------
-- * Converters of Data Types

-- | Modify a signal by down-sampling. 
--
-- > kres downsamp asig [, iwlen]
--
-- doc: <http://www.csounds.com/manual/html/downsamp.html>
downsamp :: Sig -> Sig 
downsamp = opc1 "downsamp" [(k, [a,i])]

-- | Modify a signal by up-sampling. 
--
-- > ares upsamp ksig
--
-- doc: <http://www.csounds.com/manual/html/upsamp.html>
upsamp :: Sig -> Sig
upsamp = opc1 "upsamp" [(a, [k])]

-- | Converts a control signal to an audio signal using linear interpolation. 
--
-- > ares interp ksig [, iskip] [, imode]
--
-- doc: <http://www.csounds.com/manual/html/interp.html>
interp :: Sig -> Sig
interp = opc1 "interp" [(a, [k,i,i])]

------------------------------------------------------------------------------------------
-- amplitude conversions

-- | Floating number types: 'Sig' or 'D'.
class Val a => Nums a 
instance Nums Sig
instance Nums D

conv :: Nums a => NumOp -> a -> a
conv op a = noRate $ ExpNum $ PreInline op [toPrimOr $ toE a]


-- | Returns the amplitude equivalent of the decibel value x. Thus:
--
-- *    60 dB = 1000
--
-- *    66 dB = 1995.262
--
-- *    72 dB = 3891.07
--
-- *    78 dB = 7943.279
--
-- *    84 dB = 15848.926
--
-- *    90 dB = 31622.764
--
-- > ampdb(x)  (no rate restriction)
--
-- doc: <http://www.csounds.com/manual/html/ampdb.html>

ampdb :: Nums a => a -> a
ampdb = conv Ampdb 

-- | Returns the amplitude equivalent of the full scale decibel (dB FS) value x. 
-- The logarithmic full scale decibel values will be converted to linear 16-bit signed integer values from −32,768 to +32,767. 
--
-- > ampdbfs(x)  (no rate restriction)
--
-- doc: <http://www.csounds.com/manual/html/ampdbfs.html>

ampdbfs :: Nums a => a -> a
ampdbfs = conv Ampdbfs

-- | Returns the decibel equivalent of the raw amplitude x. 
--
-- > dbamp(x)  (init-rate or control-rate args only)
--
-- doc: <http://www.csounds.com/manual/html/dbamp.html>

dbamp :: Nums a => a -> a
dbamp = conv Dbamp

-- | Returns the decibel equivalent of the raw amplitude x, relative to full scale amplitude. Full scale is assumed to be 16 bit. New is Csound version 4.10. 
--
-- > dbfsamp(x)  (init-rate or control-rate args only)
--
-- doc: <http://www.csounds.com/manual/html/dbfsamp.html>
dbfsamp :: Nums a => a -> a 
dbfsamp = conv Dbfsamp 

------------------------------------------------------------------------------------------
-- pitch conversions

-- | Converts a pitch-class value to cycles-per-second. 
--
-- > cpspch (pch)  (init- or control-rate args only)
--
-- doc: <http://www.csounds.com/manual/html/cpspch.html>
cpspch :: Nums a => a -> a
cpspch = conv Cpspch

-----------------------------------------------------
-- * Printing and Strings

-- ** Simple Printing

-- | These units will print orchestra init-values. 
--
-- > print iarg [, iarg1] [, iarg2] [...]
--
-- doc: <http://www.csounds.com/manual/html/print.html>
printi :: [D] -> SE ()
printi a1 = se_ $ opcs "print" [(x, repeat i)] a1

-- | Prints one k-rate value at specified intervals. 
--
-- > printk itime, kval [, ispace]
--
-- doc: <http://www.csounds.com/manual/html/printk.html>
printk :: D -> Sig -> SE ()
printk a1 a2 = se_ $ opc2 "printk" [(x, [i,k,i])] a1 a2


-- ** Formatted Printing

-- ** String Variables

-- | sprintf write printf-style formatted output to a string variable, similarly to the C function sprintf(). sprintf runs at i-time only. 
--
-- > Sdst sprintf Sfmt, xarg1[, xarg2[, ... ]]
--
-- doc: <http://www.csounds.com/manual/html/sprintf.html>
sprintf :: Str -> [D] -> Str
sprintf a1 a2 = opcs "sprintf" [(s, s:repeat i)] (toE a1 : map toE a2)

-- | sprintfk writes printf-style formatted output to a string variable, similarly to the C function sprintf(). sprintfk runs both at initialization and performance time. 
--
-- > Sdst sprintfk Sfmt, xarg1[, xarg2[, ... ]]
--
-- doc: <http://www.csounds.com/manual/html/sprintfk.html>
sprintfk :: Str -> [Sig] -> Str
sprintfk a1 a2 = opcs "sprintfk" [(s, s:repeat k)] (toE a1 : map toE a2)

-- ** String Manipulation And Conversion

-- | Concatenate two strings and store the result in a variable. strcat runs at i-time only. It is allowed for any of the input arguments to be the same as the output variable. 
--
-- > Sdst strcat Ssrc1, Ssrc2
--
-- doc: <http://www.csounds.com/manual/html/strcat.html>
strcat :: Str -> Str -> Str
strcat = opc2 "strcat" [(s, [s,s])]

-- |  Concatenate two strings and store the result in a variable. strcatk does the 
-- concatenation both at initialization and performance time. It is allowed for any of the input arguments to be the same as the output variable. 
--
-- > Sdst strcatk Ssrc1, Ssrc2
--
-- doc: <http://www.csounds.com/manual/html/strcatk.html>
strcatk :: Str -> Str -> Str
strcatk = opc2 "strcatk" [(s, [s,s])]


