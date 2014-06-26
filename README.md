perfseek -- Aircraft performance estimation
========

It is assumed that the flow field will exhibit parabolic characteristic behaviour and so necessitates a time-marching solution of the entire problem domain.  This is fine because perfseek gives a rather crude performance estimate anyways, and will not involve grid-mesh generation around a defined boundary (i.e. no space-marching).

Rather, in order to keep it simple and do what amounts to a SWAG of the performance qualities, the aircraft is abstracted away into a sort of arbitrary body having the required aerodynamic properties.  Users wanting a solution of the fluid flows over a given part of a defined model or grid/mesh should investigate traditional CFD suites such as Ansys Fluent or OpenFOAM.
