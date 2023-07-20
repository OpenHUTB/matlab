function h=initializeClass(h,varargin)





    InitializeObjectProperties(h,nargin-1,varargin);




    function InitializeObjectProperties(h,nargs,args)

        if nargs<=1,

            linkfoundation.autointerface.baselink.checkOutLicense(args);
            return;
        end

        if(mod(nargs,2)~=0)
            error(message('ERRORHANDLER:utils:ConstructorInputsNotInPairs','BASELINK'));
        end


        for i=1:2:nargs
            prop=lower(args{i});
            val=args{i+1};

            switch prop
            case 'timeout'

                h.timeout=double(val);
            otherwise


            end
        end

        linkfoundation.autointerface.baselink.checkOutLicense(args);

