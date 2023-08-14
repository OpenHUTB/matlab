function fileName=getDisplayIcon(this)




    if~isempty(this.ErrorMessage)

        fileName='toolbox/rptgen/resources/warning.png';
    elseif this.Parentable
        fileName='toolbox/rptgen/resources/Component_parentable.png';
    else
        fileName='toolbox/rptgen/resources/Component_unparentable.png';
    end



