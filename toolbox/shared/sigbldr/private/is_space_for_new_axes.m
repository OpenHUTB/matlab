function out=is_space_for_new_axes(axesExtent,geomConst,numAxes)








    out=(axesExtent(4)-10)>(geomConst.axesOffset(2)+numAxes*(geomConst.axesVdelta+1));