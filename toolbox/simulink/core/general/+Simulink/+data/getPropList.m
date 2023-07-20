function propList=getPropList(hObj,varargin)







    assert((mod(nargin,2)==1),...
    'Must be an odd number of input arguments');

    switch Simulink.data.getScalarObjectLevel(hObj)
    case 1
        hClass=classhandle(hObj);
        propList=hClass.Properties;

        if nargin>1

            nPairs=(nargin-1)/2;
            args=reshape(varargin,2,nPairs)';

            for argIdx=1:nPairs
                attribName=args{argIdx,1};
                attribVal=args{argIdx,2};

                switch attribName
                case 'GetAccess'
                    attribName='PublicGet';
                    attribVal=l_IsEqualToOnOff(attribVal,'public');
                case 'SetAccess'
                    attribName='PublicSet';
                    attribVal=l_IsEqualToOnOff(attribVal,'public');
                case 'Transient'
                    attribName='Serialize';
                    attribVal=l_IsEqualToOnOff(attribVal,false);
                case 'Hidden'
                    attribName='Visible';
                    attribVal=l_IsEqualToOnOff(attribVal,false);
                otherwise
                    assert(false,'Unexpected property attribute');
                end

                args{argIdx,1}=attribName;
                args{argIdx,2}=attribVal;
            end


            for propIdx=length(propList):-1:1
                thisProp=propList(propIdx);
                for argIdx=1:nPairs
                    attribName=args{argIdx,1};
                    attribVal=args{argIdx,2};

                    if strcmp(attribName,'Visible')
                        attribRoot=thisProp;
                    else
                        attribRoot=thisProp.AccessFlags;
                    end

                    if~strcmp(attribRoot.(attribName),attribVal)

                        propList(propIdx)=[];
                        break;
                    end
                end
            end
        end

    case 2
        hClass=metaclass(hObj);
        propList=findobj(hClass.PropertyList,varargin{:});

    otherwise
        propList='';
        if isobject(hObj)
            try
                hClass=metaclass(hObj);
                propList=findobj(hClass.PropertyList,varargin{:});
            catch
            end
        end
    end




    function retVal=l_IsEqualToOnOff(str1,str2)

        if isequal(str1,str2)
            retVal='on';
        else
            retVal='off';
        end



