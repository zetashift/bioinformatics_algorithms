for f in `ls *.org`; do
    filename="${f%.*}"
    pandoc -s ${f} -o ./markdown/${filename}.md
done
