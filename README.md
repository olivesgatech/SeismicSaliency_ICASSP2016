# SeismicSaliency_ICASSP2016

## About the Paper

The codes here implement our work in the following paper: 

M. Shafiq, T. Alshawi, Z. Long, and G. AlRegib, "SalSi: A New Seismic Attribute For Salt Dome Detection," IEEE Intl. Conf. on Acoustics, Speech and Signal Processing (ICASSP), Shanghai, China, Mar. 20-25, 2016.

Please cite our paper if you use the codes.

## How to Run

1. In Matlab, make this directory as the working directory.

2. Make sure you add following directory in your Matlab search path by 
   using "Set Path" and "Add with Subfolders" in the Matlab Home-Environment 
   tab: "\Seismic_Data\..."

3. Run the following Program from "SaliencyForSeismic" folder

   >> MainFile_determinSaliencyForSaltDomes.m

   to generate the Mat file "salMapAllSlices.mat" required to simulation, 
   already present in Mat Files folder.

4. Run the program:

   >> Main_Fig3.m
   
   to reproduce the Figure 3 of the paper.

5. Run the program:

   >> Main_Fig4_Table1.m
   
   to reproduce the Figure 4 and Table 1 of the paper.

## Contact Info

The code was written by 
```
Muhammad Amir Shafiq
School of Electrical and Computer Engineering 
Georgia Institute of Technology, Atlanta, GA, USA.
```
If you have found any bugs or have any questions/suggestions, 
please contact
```
amirshafiq@gatech.edu 
amirshafiq@gmail.com
```
Last Modified: 24-Sep-2015
