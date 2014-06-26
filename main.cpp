#include <iostream>
#include "inih/INIReader.h"

//yes, this is ugly
// change this to a single struct or something instead of 25 arguments
extern "C" void c_levelspeed(double *T0, 
			     double *RHO0,
			     double *P0,
			     double *GAMMA,
			     double *MOLARMASSAIR,
			     double *HEATRATIO, 
			     double *GASCONSTANT, 
			     double *G, 
			     double *S, 
			     double *oswald, 
			     double *wingspan, 
			     double *Cd0, 
			     double *diameter, 
			     double *Clmax, 
			     double *Cprop, 
			     double *gearratio, 
			     double *Mplim, 
			     double *Cmprop, 
			     double *enginespeed, 
			     double *HPbrake, 
			     double *altitude, 
			     double *n, 
			     double *weight, 
			     double *HP2WATTS, 
			     double *pi);

int main(int argc, char* argv[])
{  
  if( argc != 2 ){
    std::cout << "Usage: "<< argv[0] << " <path to config file>" << std::endl;
    return 1;
  }
  
  INIReader reader(argv[1]);
  
  if (reader.ParseError() < 0) {
    std::cout << "Fatal Error:  Unable to load "<<argv[1]<<"!\n";
    return 1;
  }
  std::cout << "Loaded "<<argv[1]<<" successfully." << std::endl;

  double T0 = reader.GetReal("atmosphere", "T0", 288.15);
  double Rho0 = reader.GetReal("atmosphere", "Rho0", 1.225);
  double P0 = reader.GetReal("atmosphere", "P0", 101325.0);
  double Gamma = reader.GetReal("atmosphere", "Gamma", 0.0065);
  double MolarMassAir = reader.GetReal("atmosphere", "MolarMassAir", 0.0289644);
  double HeatRatio = reader.GetReal("atmosphere", "HeatRatio", 1.402);
  double GasConstant = reader.GetReal("atmosphere", "GasConstant", 8.31432);
  double G = reader.GetReal("atmosphere", "G", 9.81);

  double S = reader.GetReal("aircraft", "S", 1);
  double oswald = reader.GetReal("aircraft", "oswald", 1);
  double wingspan = reader.GetReal("aircraft", "wingspan", 1);
  double Cd0 = reader.GetReal("aircraft", "Cd0", 0.01);
  double diameter = reader.GetReal("aircraft", "diameter", 1);
  double Clmax = reader.GetReal("aircraft", "Clmax", 1);
  double Cprop = reader.GetReal("aircraft", "Cprop", 1);
  double gearratio = reader.GetReal("aircraft", "gearratio", 1);
  double Mplim = reader.GetReal("aircraft", "MPlim", 1);
  double Cmprop = reader.GetReal("aircraft", "Cmprop", 1);
  double enginespeed = reader.GetReal("aircraft", "enginespeed", 1);
  double HPbrake = reader.GetReal("aircraft", "Pbrake", 1000);
  double altitude = reader.GetReal("aircraft", "altitude", 1);
  double n = reader.GetReal("aircraft", "n", 1);
  double weight = reader.GetReal("aircraft", "weight", 1000);

  double pi=3.1415927;
  double HP2WATTS=746;
  
  c_levelspeed(&T0, 
	       &Rho0, 
	       &P0, 
	       &Gamma, 
	       &MolarMassAir, 
	       &HeatRatio, 
	       &GasConstant, 
	       &G,
	       &S,
	       &oswald,
	       &wingspan,
	       &Cd0,
	       &diameter,
	       &Clmax,
	       &Cprop,
	       &gearratio,
	       &Mplim,
	       &Cmprop,
	       &enginespeed,
	       &HPbrake,
	       &altitude,
	       &n,
	       &weight,
	       &HP2WATTS,
	       &pi
	       );

  return 0;
}
