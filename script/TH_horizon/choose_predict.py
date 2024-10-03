>#!/usr/bin/python3

#Ligne de commande : 
##python3 Choose_predict.py -i input_file.gff -o output_file.gff

#Importer packages: 
import argparse 

def choose_predict(input_file, output_file):
    """
    Choose the longest gene prediction on overlaping positions 
    """
        
    #open input file and read lines : 
    f=open(input_file,"r")
    in_file=f.readlines()       

    #open output file :
    out=open(output_file,"w")

    for l in in_file: 
        line=l.strip().split("\t")
        Size_a=int(line[4])-int(line[3])
        Size_b=int(line[14])-int(line[13])

        if Size_a >= Size_b :
            out.write("{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\n".format(str(line[0]),str(line[1]),str(line[2]),str(line[3]),str(line[4]),str(line[5]),str(line[6]),str(line[7]),str(line[8]),str(line[9])))
        else : 
            out.write("{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\n".format(str(line[10]),str(line[11]),str(line[12]),str(line[13]),str(line[14]),str(line[15]),str(line[16]),str(line[17]),str(line[18]),str(line[19])))


def main(): 
    parser = argparse.ArgumentParser()
        
    #input:
    parser.add_argument('-i', '--input', type=str, help='GFF file from augustus and intersect')
    #output: 
    parser.add_argument('-o', '--output', type=str, help='GFF output file')                     

    args = parser.parse_args()
        
    #Lancer fonctions: 
    print("Starting to choose")
    choose_predict(args.input,args.output)
    print("The choosing process had been completed")
        

if "__main__" == __name__:
    main()

