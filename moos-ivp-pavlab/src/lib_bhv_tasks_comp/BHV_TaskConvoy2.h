
/* **************************************************************
  NAME: Raymond Turrisi 
  ORGN: Dept of Mechanical Engineering, MIT, Cambridge MA
  FILE: BHV_TaskConvoy2.h
  CIRC: November 2023
  DESC: 
    A shallow bidding function which constructs a bid from the
    distance to a target and the complementaryness of an agent
    heading and the angle to the target

  LICENSE:
    This is unreleased BETA code. No permission is granted or
    implied to use, copy, modify, and distribute this software 
    except by the author(s), or those designated by the author.
************************************************************** */
 
#ifndef BHV_TASK_CONVOY_HEADER
#define BHV_TASK_CONVOY_HEADER

#include <string>
#include <vector>
#include "IvPTaskBehavior.h"

class IvPDomain;
class BHV_TaskConvoy2 : public IvPTaskBehavior {
public:
  BHV_TaskConvoy2(IvPDomain);
  ~BHV_TaskConvoy2() {}

  // virtuals defined
  void   onHelmStart();
  double getTaskBid();
  bool   setParam(std::string, std::string);

  std::vector<VarDataPair> applyFlagMacros(std::vector<VarDataPair>);

  void         onIdleState();
  IvPFunction* onRunState();

 protected:  // Configuration Parameters

 protected:  // State Variables

};

#ifdef WIN32
   // Windows needs to explicitly specify functions to export from a dll
   #define IVP_EXPORT_FUNCTION __declspec(dllexport) 
#else
   #define IVP_EXPORT_FUNCTION
#endif

extern "C" {
  IVP_EXPORT_FUNCTION IvPBehavior * createBehavior(std::string name, IvPDomain domain) 
  {return new BHV_TaskConvoy2(domain);}
}
#endif






