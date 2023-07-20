function success=setMaskParams(slBlockName,pv)





    success=true;
    if~isempty(pv)



        pv=pv';



        pv=pv(:)';


        c=[{'set_param',slBlockName},pv];

        try

            feval(c{:});
        catch %#ok<CTCH>
            success=false;
        end
    end
end