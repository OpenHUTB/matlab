function resp=compareAndWarnCCSVersions(varargin)













    narginchk(1,2);
    product_name='Embedded Coder';
    if nargin>=1
        if~isempty(varargin{1})&&isnumeric(varargin{1})
            apiversion=int32(varargin{1});
        else
            error(message('TICCSEXT:util:InvalidAPIVersionFormat'));
        end
    end

    resp=isSupportedApiVersion(apiversion);

    if resp==3,




        if nargin==2&&ischar(varargin{2})&&(strcmpi(varargin{2},'warn')||strcmpi(varargin{2},'warn-on-advance-versions'))
            warning(message('TICCSEXT:util:UntestedNewIdeVersion',product_name,product_name));
        end


    elseif resp==2,

        return;

    elseif resp==1,

        return;

    else



        error(message('TICCSEXT:util:UnsupportedOldIdeVersion',product_name,product_name));
    end



    function issupported=isSupportedApiVersion(ver)








        ver=str2double([num2str(ver(1)),'.',num2str(ver(2))]);

        supported=supportedApiVersionsList;
        oldestSupportedVersion=str2double([num2str(supported(1,1)),'.',num2str(supported(1,2))]);
        newestSupportedVersion=str2double([num2str(supported(end,1)),'.',num2str(supported(end,2))]);

        if ver<oldestSupportedVersion

            issupported=0;
        elseif ver>newestSupportedVersion

            issupported=3;
        else
            if ver==newestSupportedVersion
                issupported=2;
            else
                issupported=1;
            end
        end


        function[apiver,ccsver]=supportedApiVersionsList


























            apiver=[1,50;...
            ];


            ccsver={3.3;...
            };












