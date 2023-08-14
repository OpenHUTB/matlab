function[adj,chnlnodes]=getUpdatedAdj(J,mdl,mdlHierInfo,chnlnodes,iostruct)




    J.Mi.InputName=iostruct.FullInputName;
    J.Mi.OutputName=iostruct.FullOutputName;
    J.Mi.InputPortNumbers=iostruct.FullInputPort;
    J.Mi.OutputPortNumbers=iostruct.FullOutputPort;

    [adj,nx,ny,nu,nY,nU]=linearize.advisor.utils.J2Adj(J);

    chnlnodes=linearize.advisor.graph.processIONodes(...
    chnlnodes,J,nx,ny,nu,nY,nU,mdl,mdlHierInfo,[]);