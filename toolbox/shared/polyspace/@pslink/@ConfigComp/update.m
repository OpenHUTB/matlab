










function update(hObj,event)

    switch event
    case 'attach'


    case 'pre-activate'


    case 'activate'
        bd=hObj.getBlockDiagram();
        if~isempty(bd)
            hObj.PSSystemToAnalyze=bd.getFullName();
        end

    otherwise

    end


