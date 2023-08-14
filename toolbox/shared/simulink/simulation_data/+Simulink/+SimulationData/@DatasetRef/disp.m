function disp(this)



    if length(this)~=1
        Simulink.SimulationData.utNonScalarDisp(this);
        return;
    end


    mc=metaclass(this);
    if feature('hotlinks')
        fprintf('  <a href="matlab: help %s">%s</a>\n',mc.Name,mc.Name);
    else
        fprintf('  %s\n',mc.Name);
    end

    try

        mObj=message('SimulationData:Objects:DatasetCharacteristicsHeading');
        fprintf('  %s\n',mObj.getString);

        if strcmp(this.Location,this.ResolvedLocation)||...
            isempty(strtrim(this.ResolvedLocation))
            fprintf('          Location: %s\n',this.Location);
        else
            fprintf('          Location: %s (%s)\n',this.Location,this.ResolvedLocation);
        end

        fprintf('        Identifier: %s\n',this.Identifier);
        fprintf('\n');
        this.resolve();
        if this.Dataset_.numElements()~=1
            mObj=message('SimulationData:Objects:DatasetRefResolvedDatasetHeading',...
            this.Dataset_.Name,this.Dataset_.numElements());
        else
            mObj=message('SimulationData:Objects:DatasetRefResolvedDatasetHeadingSingleElement',...
            this.Dataset_.Name);
        end
        fprintf('  %s\n',mObj.getString);


        displayElements(this.Dataset_);
    catch me
        mObj=message('SimulationData:Objects:DatasetRefCannotResolveHeading');
        fprintf('  %s %s\n',mObj.getString,me.message);
    end

end
