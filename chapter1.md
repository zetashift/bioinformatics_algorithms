# Genome replication

Before a cell can divide, it must first replicate it's genome so that
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

# Finding the Origin of Replication

`Input`: A DNA String *Genome* `Output`: The location of *ori* in
*Genome*

Is this a clearly stated \*computational problem? No it\'s not! Can we
design a computational approach to finding *ori*?

# Hidden Messages in replication origin

Here we will be using *Vibrio cholerae*, bacteria that causes cholera
as an example of how to find the *ori*. We already know the *ori*, but
let's see what makes the region special, so we can design a
computational approach for finding ori in other bacteria.

Here is *Vibrio cholerae*\'s replication origin:

```
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
“hidden message” is not defined precisely.

# Counting words


We can try to decipher the message in *ori* by trying to find any
surprisingly frequent “words”. For various biological processes,
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

```nim
proc patternCount*(text: string, pattern: string): int =
  var count = 0

  # I use `high` here instead of `len` because of ease of use.
  for idx in 0..text.high - pattern.len:
    if text[idx .. idx+pattern.high] == pattern:
        count += 1

  result = count

```

The frequent words problem
==========================

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

```nim
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

```

This algorithm has horrible runtime complexity: O(\|Text\|^2^ \* k). So
can we do better than this? Yes! First we build a frequency table and
every time we encounter a k-mer we add 1 to it\'s count in the table.

```nim
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
func betterFrequentWords*(text: string, k: int): seq[string] =
  result = newSeq[string]()
  let freqTable = frequencyTable(text, k)
  let (_, max) = freqTable.largest

  for pattern, count in freqTable:
    if count == max: result.add(pattern)

```

Unleashing this algorithm on *Vibrio cholerae* gives us a frequent k-mer
table and there we can see that the 9-mers are surprising.

# Some hidden messages are more surprising than others


## Nucleotides and basics DNA


`A` complements `T` `C` complements `G` The beginning of a DNA strand is
called the **5\', five prime** and the end **3\', three prime**.

# Reverse complement of a DNA string


We should be able to get the complement of a DNA strand, which is taking
the complement of each nucleotide and then reversing the string with the
following code:

```nim
import algorithm

func reverseComplement*(strand: string): string =
  const complementTable = {'A' : 'T', 'C' : 'G', 'T': 'A', 'G' : 'C'}.toTable
  for nucl in strand:
    result.add(complementTable[nucl])

  result.reverse

assert reverseComplement("AAAACCCGGT") == "ACCGGGTTTT"
```

Running this algorithm on *Vibrio cholerae\'s ori* we get
`ATGATCAAG (or CTTGATCAT)` as a pattern that might be a hidden message.

We should first check if there aren't any more multiple occurrences of
these patterns in other regions. A pattern matching problem: `Input`:
Strings *Pattern* and *Genome* `Output`: All starting positions in
*Genome* where *Pattern* appears as a substring.

```nim
func patternMatch*(genome, pattern: string): seq[int] =
  result = @[] # The indices where the pattern starts as a substring
  for idx in 0..genome.high-pattern.len:
    if genome[idx ..< idx+pattern.len] == pattern:
      result.add(idx)

doAssert patternMatch("GATATATGCATATACTT", "ATAT") == @[1, 3, 9]
```

*Can we conclude that ATGATCAAG/CTTGATCAT also represents a DnaA box in
other bacterial genomes?* No we can\'t, for several reasons like
`ATGATCAAG/CTTGATCAT` being a statistical fluke in Vibrio cholerae or
that bacteria simply have different DnaA boxes, some bacteria don\'t
even have the same clumping of patterns like *Vibrio cholerae* so the
ori in those bacteria must be different!

# An explosion of hidden messages

Let\'s change our computational focus: instead of finding clumps of a
specific k-mer, let\'s try to find *every* k-mer that forms a clump in
the genome. The locations of these clumps might give more info.

We will slide a window of fixed length `L` along the genome, looking for
regions where the k-mer appears several times in short succession. For
current use we will use `L = 500`, this reflects the typical length of
*ori* in bacterial genomes. Given integers `L` and `t`, a k-mer
*Pattern* forms a `(L, t)-clump` inside Genome if they're in an interval
of Genome of length `L` in which this k-mer appears at least *t* times.
This brings us to the following problem, the clump finding problem.
`Input`: A string *Genome*, integers *k*, *L* and *t*. `Output`: All
distinct k-mers forming `(L, t)-clumps` in *Genome*.

We can re-use the `FrequencyTable` function for this. `FrequencyTable`
will produce a frequency table for a given window of a string of length
*L*. We need to check if there are any string keys in the table whose values
are equal to *t*. These keys that are not present in any other window of
*Text* will be added to the output.

```nim
proc findClumps*(text: string, k, l, t: int): HashSet[string] =
  result = initHashSet[string]()
  let n = text.high
  for i in 0 .. n - l:
    let
      window = text[i ..< i+l]
      freqMap = frequencyTable(window, k)

    for key, value in freqMap:
      if value >= t:
        result.incl(key)

let sampleGenome = "CGGACTCGACAGATGTGAAGAAATGTGAAGACTGAGTGAAGAGAAGAGGAAACACGACACGACATTGCGACATAATGTACGAATGTAATGTGCCTATGGC"

echo findClumps(sampleGenome, 5, 75, 4)
```

But even with this it\'s hard to find *ori* in *E.coli*.

# The simplest way to replicate DNA

Let\'s discuss the replication process. Complementary DNA strands run in
opposite directions, starting at ori. The strands unwind, creating two
**replication forks**, these **replication forks** extends all the way
to the end, called **replication terminus**, also called *ter*. The
**replication terminus** is roughly located opposite to *ori*. DNA
polymerase does NOT wait for the parent strands to completely unwind
before starting the copying process. It starts copying while the strands
are unraveling. DNA polymerase does not a **primer**, a short
complementary segment that binds to the parent strand and tells the DNA
polymerase to start. The replication starts by adding nucleotides,
beginning with the primer and proceeding around the chromosome from
*ori* to *ter*. DNA polymerase is **unidirectional**. They only move in
3' -> 5' direction.

## Unidirectionality


This unidirectionality means we need to revise our model of replication.
If we walk along DNA connecting *ori* to *ter* then we'll see four
different half-strands of parent DNA connecting *ori* to *ter*. These
four half-strands consist of:

- **two forward half-strands** in 5' -> 3' direction
- **two reverse half-strands** in 3' -> 5' direction
