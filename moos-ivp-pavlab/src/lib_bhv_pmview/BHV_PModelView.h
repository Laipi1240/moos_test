/***********************************************************/
/*    NAME: Michael Benjamin                               */
/*    ORGN: Dept of Mechanical Eng, MIT Cambridge MA       */
/*    FILE: BHV_PModelView.h                               */
/*    DATE: Nov 3rd, 2023                                  */
/***********************************************************/
 
#ifndef BHV_PMODEL_VIEW_HEADER
#define BHV_PMODEL_VIEW_HEADER

#include <string>
#include "IvPBehavior.h"

class BHV_PModelView : public IvPBehavior {
public:
  BHV_PModelView(IvPDomain);
  ~BHV_PModelView() {}
  
  bool    setParam(std::string, std::string);
  void    onSetParamComplete();
  IvPFunction* onRunState();
  void    onIdleState() {};
  void    onIdleToRunState() {};
  void    onRunToIdleState();

 protected:
  bool    updateInfoIn();
  IvPFunction* buildOF();

  void    drawTurnPath();
  void    eraseTurnPath();

 protected: // Config vars

  std::string m_edge_color;
  std::string m_vertex_color;
  double m_vertex_size;
  
 protected: // State vars
  
};

#define IVP_EXPORT_FUNCTION

extern "C" {
  IVP_EXPORT_FUNCTION IvPBehavior * createBehavior(std::string name, IvPDomain domain) 
  {return new BHV_PModelView(domain);}
}
#endif
