function[success,statusMsg]=setMaskParams(this,slBlockName,pv)%#ok<INUSL>





    success=true;
    statusMsg=[];
    if~isempty(pv)



        pv=pv';



        pv=pv(:)';


        c=[{'set_param',slBlockName},pv];

        try

            feval(c{:});
        catch ME %#ok<CTCH>
            statusMsg=ME.message;
            success=false;
        end
    end
end