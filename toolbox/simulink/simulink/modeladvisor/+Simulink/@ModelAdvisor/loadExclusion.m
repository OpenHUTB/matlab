function[success]=loadExclusion(this,filename)




    success=false;%#ok<NASGU>

    try
        [~,~,ext]=fileparts(filename);
        if isempty(ext)
            filename=[filename,'.mat'];
        end
        if~exist(filename,'file')
            success=false;
            return;
        end


        load(filename);


        this.removeExclusion;


        for i=1:length(exclusion.ExclusionCellArray)
            this.addExclusion(exclusion.ExclusionCellArray{i});
        end

        success=true;

    catch E


        disp(E.message);
        rethrow(E);
    end
