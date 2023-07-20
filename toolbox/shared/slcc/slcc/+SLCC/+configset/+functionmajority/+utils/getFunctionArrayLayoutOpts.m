function[opts]=getFunctionArrayLayoutOpts()



    persistent loc_opts;

    if isempty(loc_opts)
        loc_opts={...
        getString(message('RTW:configSet:ArrayLayout_Column_Major')),...
        getString(message('RTW:configSet:ArrayLayout_Row_Major')),...
        getString(message('RTW:configSet:ArrayLayout_Any'))...
        };
    end

    opts=loc_opts;
end
