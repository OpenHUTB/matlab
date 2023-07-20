function varargout=getMailboxUpperBound(h,IRmodelInfo,eCANMode)






    if nargout>=2

        varargout{1}=[];
        varargout{2}=[];

        if nargin==2
            eCANMode='eCAN_AMode';
        end

        if isfield(IRmodelInfo,eCANMode')
            if strcmp(IRmodelInfo.(eCANMode),'off'),
                ubound_A=15;
                modestring_A='SCC';
            else
                ubound_A=31;
                modestring_A='HECC';
            end
            varargout{1}=ubound_A;
            varargout{2}=modestring_A;
        end
    end

    if nargout==4

        varargout{3}=[];
        varargout{4}=[];

        eCANMode='eCAN_BMode';

        if isfield(IRmodelInfo,eCANMode)
            if strcmp(IRmodelInfo.(eCANMode),'off'),
                ubound_B=15;
                modestring_B='SCC';
            else
                ubound_B=31;
                modestring_B='HECC';
            end
            varargout{3}=ubound_B;
            varargout{4}=modestring_B;
        end
    end