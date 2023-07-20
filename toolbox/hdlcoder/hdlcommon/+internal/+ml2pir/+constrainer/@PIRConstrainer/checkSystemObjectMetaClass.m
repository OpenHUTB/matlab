function checkSystemObjectMetaClass(this,node,className)




    mc=meta.class.fromName(className);



    mtds=cell(1,numel(mc.MethodList));
    [mtds{:}]=mc.MethodList.Name;

    resetImpl=mc.MethodList(strcmp(mtds,'resetImpl'));
    if~isempty(resetImpl)&&~strcmp(resetImpl.DefiningClass.Name,'matlab.system.SystemImpl')
        this.addMessage(node,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:UnsupportedResetImplAuthoredSystemObject',...
        className);
    end


    for ii=1:numel(mc.PropertyList)
        prop=mc.PropertyList(ii);
        if~strncmp(prop.DefiningClass,'matlab.system',13)&&...
            ~prop.Nontunable&&(strcmp(prop.GetAccess,'public')||...
            strcmp(prop.SetAccess,'public'))
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            'hdlcommon:matlab2dataflow:UnsupportedTunableSystemObject');
            break;
        end
    end

end
