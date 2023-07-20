function out=CodeCoverageSettings(cs,~,direction,widgetVals)


    if direction==0
        paramVal=cs.getProp('CodeCoverageSettings');
        out={paramVal.CoverageTool,''};

    elseif direction==1
        val=widgetVals{1};

        [toolNames,toolClasses]=coder.coverage.CodeCoverageHelper.getTools(true);
        toolNum=find(strcmp(val,toolNames),1,'first');
        toolClass=toolClasses(toolNum);
        toolName=toolNames{toolNum};

        out=coder.coverage.CodeCoverageHelper.getSettingsForClass...
        (cs,toolName,toolClass);
    end

