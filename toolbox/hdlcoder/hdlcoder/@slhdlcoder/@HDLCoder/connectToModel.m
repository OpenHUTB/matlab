function connectToModel(this)



    if isempty(this.getStartNodeName)
        error(message('hdlcoder:engine:invalidmodelname'));
    end



    if isprop(get_param(this.getStartNodeName,'handle'),'ProtectedModel')&&...
        strcmpi(get_param(get_param(this.getStartNodeName,'handle'),'ProtectedModel'),'on')
        error(message('hdlcoder:validate:ModelRefProtectedModelAtTopLevel'));
    end


    this.ModelConnection.initModel;
end
