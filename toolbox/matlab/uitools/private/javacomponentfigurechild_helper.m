function[hcomponent,hcontainer]=javacomponentfigurechild_helper(peer,position,parent)




    assert(isa(peer,'com.mathworks.hg.peer.FigureChild'));

    component=peer.getFigureComponent;
    [~,hcontainer]=matlab.ui.internal.JavaMigrationTools.suppressedJavaComponent(component,position,parent);
    hcomponent=handle(peer,'callbackproperties');






    setappdata(hcontainer,'JavaPeer',hcomponent);

    peer.setUIContainer(double(hcontainer));
