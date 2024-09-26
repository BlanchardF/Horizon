#!/bin/bash

species=${1}
type=${2}

# Variables
input="/beegfs/data/fblanchard/horizon/Metaeuk/${species}/${species}_taxResult_tax_per_contig.tsv"
output="/beegfs/data/fblanchard/horizon/Metaeuk/${species}/${species}_taxonomic_assignment_quality.txt"

# Stat assigné au bon ordre
echo "liste des différentes annotations à l'ordre"
grep "o_" "${input}" | awk -F';' '{for(i=1;i<=NF;i++) if($i ~ /o_/) print $i}' | sort | uniq -c 

echo "total des scaffolds"
wc -l < "${input}"

# Total des scaffolds assignés
grep "o_" "${input}" | awk -F';' '
{
    for (i=1; i<=NF; i++) {
        if ($i ~ /o_/) {
            values[$i]++;
        }
    }
}
END {
    total = 0;
    for (o in values) {
        total += values[o];
    }
    print "total des scaffolds assignés: " total;
}'

# Taille de génome par ordre
awk -F';' '
{
    for (i=1; i<=NF; i++) {
        if ($i ~ /o_/) {
            o_value = $i;
            if (match($0, /size[^0-9]*([0-9]+)/, arr)) {
                size_value = arr[1];
                sizes[o_value] += size_value;
            }
        }
    }
}
END {
    for (o in sizes) {
        print o ": " sizes[o];
    }
}' "${input}"

# Taille de génome pour lepidoptera et autres
awk -F';' -v input="${input}" '
{
    for (i=1; i<=NF; i++) {
        if ($i ~ /o_/) {
            o_value = $i;
            if (match($0, /size[^0-9]*([0-9]+)/, arr)) {
                size_value = arr[1];
                sizes[o_value] += size_value;
            }
        }
    }
}
END {
    total_other = 0;
    total_lepidoptera = sizes["o_Lepidoptera"];

    for (o in sizes) {
        if (o != "o_Lepidoptera") {
            total_other += sizes[o];
        }
    }

    total_combined = total_lepidoptera + total_other;

    print "Total for all o_ except o_Lepidoptera: " total_other;
    print "Total for o_Lepidoptera: " total_lepidoptera;
    if (total_combined > 0) {
        percentage_lepidoptera = (total_lepidoptera / total_combined) * 100;
        print "Percentage of o_Lepidoptera: " percentage_lepidoptera "%";
    } else {
        print "No data to calculate percentage.";
    }
}' "${input}"



# Stat assigné au bon ordre
echo "liste des différentes annotations au règne"
grep "k_" "${input}" | awk -F';' '{for(i=1;i<=NF;i++) if($i ~ /k_/) print $i}' | sort | uniq -c 

# Stat assigné au bon ordre
echo "liste des différentes annotations au domaine"
grep "d_" "${input}" | awk -F';' '{for(i=1;i<=NF;i++) if($i ~ /d_/) print $i}' | sort | uniq -c 