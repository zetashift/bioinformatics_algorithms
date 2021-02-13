# Chapter 1

## Genome replication

Before a cell can divide, it must first replicate it\'s genome so that
each of the two daughter cells can inherit it\'s own copy. A high-level
overview would be that two DNA strands unwind and each strand act as a
template for copying. At the end you have two pairs of complementary
strands.

Replication begins in a genomic region called the *ori*, also knows as
the **replication origin** and is carried out by **DNA polymerase**.
Replication is important not only for understanding how the cell works
but also biomedical reasons. Like gene therapy, which sometimes uses
**viral vectors**. These vectors replicate inside the cell and encode
for a therapeutic protein, to do this it must know where *ori* is in the
genome.

## Finding the Origin of Replication

`Input`: A DNA String *Genome* `Output`: The location of *ori* in
*Genome*

Is this a clearly stated \*computational problem? No it\'s not! Can we
design a computational approach to finding *ori*?

## Hidden Messages in replication origin

Here we will be using *Vibrio cholerae*, a bacteria that causes cholera
as an example of how to find the *ori*. We already know the *ori*, but
let\'s see what makes the region special, so we can design a
computational approach for finding ori in other bacteria.

Here is *Vibrio cholerae*\'s replication origin:

``` {.example}
atcaatgatcaacgtaagcttctaagcatgatcaaggtgctcacacagtttatccacaac
ctgagtggatgacatcaagataggtcgttgtatctccttcctctcgtactctcatgacca
cggaaagatgatcaagagaggatgatttcttggccatatcgcaatgaatacttgtgactt
gtgcttccaattgacatcttcagcgccatattgcgctggccaaggtgacggagcgggatt
acgaaagcatgatcatggctgttgttctgtttatcttgttttgactgagacttgttagga
tagacggtttttcatcactgactagccaaagccttactctgcctgacatcgaccgtaaat
tgataatgaatttacatgcttccgcgacgatttacctcttgatcatcgatccgattgaag
atcttcaattgttaattctcttgcctcgactcatagccatgatgagctcttgatcatgtt
tccttaaccctctattttttacggaagaatgatcaagctgctgctcttgatcatcgtttc
```

But how does the cell know to start replicating here? There must be some
**message** that tells the cell it can start here. **DnaA** is a protein
that binds to a short segment within ori knows as a **DnaA box**. This
box is a message to **DnaA** saying it should start here. But then we
get the following problem: How do we find this hidden message, when we
don\'t know what it looks like in advance?

**Hidden message problem**

`Input`: A string *Text* `Output`: A hidden message in *Text*

Sadly, this is still not a clearly stated **computational** problem. A
\"hidden message\" is not defined precisely.

## Counting words

We can try to decipher the message in *ori* by trying to find any
surprisingly frequent \"words\". For various biological processes,
certain nucleotide strings often appear surprisingly in various
biological processes. This is often because certain proteins can only
bind to DNA if a specific string of nucleotides is present, and if there
are more occurrences of the string, then it is more likely that binding
will successfully occur. (It is also less likely that a mutation will
disrupt the binding process.)

`k-mer`: A string of length *k* `Count(Text, Pattern)`: A function
returning the number of times that a `k-mer Pattern` appears as a
**substring** of `Text`. This includes overlapping text.

Here is our (first!) Nim code implementing this naive algorithm:

``` {.nim tangle="chapter1.nim"}
proc patternCount*(text: string, pattern: string): int =
  var count = 0

  # I use `high` here instead of `len` because of ease of use.
  for idx in 0..text.high - pattern.len:
    if text[idx .. idx+pattern.high] == pattern:
        count += 1

  result = count

let
  exampleText = "ACAACTATGCATACTATCGGGAACTATCCT"
  examplePattern = "ACTAT"

echo patternCount(exampleText, examplePattern)
```

## The frequent words problem

A *most frequent k-mer* is a `k-mer Pattern` that maximizes
`patternCount(Text, Pattern)` among all possible k-mers.

`Can a string have multiple most frequent k-mers?` **YES!**

We can now define a solid computational problem:

**Find the most frequent *k-mers* in a string.**

`Input: A string /Text/ and an integer /k/.`
`Output: All most frequent k-mers in /Text/.`

A naive, slow solution would be to check all *k-mers* appearing in the
string, there are `length(Text) - k+1` *k-mers* and then compute how
many times each *k-mer* appears in Text.

``` {.nim tangle="chapter1.nim"}
import sets

proc frequentWords*(text: string, k: int): HashSet[string] =
  var frequentPatterns = initHashSet[string]()
  var counts = newSeq[int](text.len-k+1)

  for idx in 0 .. text.high-k:
    let pattern = text[idx..idx+k-1]
    counts[idx] = patternCount(text, pattern)

  let maxCount = counts.max

  for idx in 0 .. text.high-k:
    if counts[idx] == maxCount:
      frequentPatterns.incl(text[idx..idx+k-1])

  result = frequentPatterns

echo frequentWords("ACAACTATGCATACTATCGGGAACTATCCT", 5)
```

This algorithm has horrible runtime complexity: O(\|Text\|^2^ \* k). So
can we do better than this? Yes! First we build a frequency table and
every time we encounter a k-mer we add 1 to it\'s count in the table.

``` {.nim tangle="chapter1.nim"}
import tables

func frequencyTable*(text: string, k: int): CountTable[string] =
  result = initCountTable[string]()
  let n = text.high
  for idx in 0 .. n - k:
    let pattern = text[idx .. idx+k-1]
    if not result.hasKey(pattern):
      result[pattern] = 1
    else:
      result.inc(pattern)

# Once we have a frequency table we can identify frequent k-mers
# by getting the maximum value and identify it's keys
proc betterFrequentWords(text: string, k: int): seq[string] =
  result = newSeq[string]()
  var frequentPatterns = newSeq[string]()
  let freqTable = frequencyTable(text, k)
  let (_, max) = freqTable.largest

  for pattern, count in freqTable:
    if count == max: result.add(pattern)

let exampleData = "ACGTTGCATGTCGCATGATGCATGAGAGCT"
echo betterFrequentWords(exampleData, 4)
```

Unleashing this algorithm on *Vibro cholerae* gives us a frequent k-mer
table and there we can see that the 9-mers are surprising.

## Some hidden messages are more surprising than others

### Nucleotides

`A` complements `T` `C` complements `G`
