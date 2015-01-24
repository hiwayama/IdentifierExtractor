set datafile separator ","
set xlabel "Version"
set ylabel "(Ct/Ct-1 < 1) / total"
set term postscript enhanced color
set output "decreasing-ratio-of-centrality.eps"
plot "./script/cs.csv" using 1:3 title "Cb" w l,\
"" using 1:5 title "Cc" lw 3 w l, \
"" using 1:7 title "Cd" lw 3 w l

