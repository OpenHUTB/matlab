function diagramH=getDiagramHandle(cbinfo)




    diagramFullName=SLStudio.Utils.getDiagramFullName(cbinfo);
    diagramH=get_param(diagramFullName,'Handle');
end
