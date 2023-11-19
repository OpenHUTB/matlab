function outvalue=simrfV2checkparam(invalue,paramname,ispositive,...
    vectorlength)

    narginchk(2,4);

    validateattributes(invalue,{'numeric'},...
    {'nonempty','vector','finite','real'},'',paramname);

    if nargin>2
        switch ispositive
        case 'gtz'
            validateattributes(invalue,{'numeric'},{'positive'},...
            '',paramname);
        case 'gtez'
            validateattributes(invalue,{'numeric'},{'nonnegative'},...
            '',paramname);
        end
    end

    if nargin>3
        validateattributes(vectorlength,{'numeric'},...
        {'nonempty','finite','real','scalar'},'',paramname);

        if numel(invalue)==1
            outvalue=invalue*ones(1,vectorlength);
        else
            validateattributes(invalue,{'numeric'},...
            {'size',[1,vectorlength]},'',paramname);
            outvalue=invalue;
        end
    else
        outvalue=invalue;
    end

end