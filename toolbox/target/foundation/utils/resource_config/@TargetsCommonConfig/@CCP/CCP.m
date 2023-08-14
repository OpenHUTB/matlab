function h=CCP(varargin)





    h=TargetsCommonConfig.CCP;

    h.help_callback=...
    'disp(''not implemented'');';

    if nargin==1
        switch varargin{1}
        case 'new'

            h.configuration_type='CCP Configuration';

            h.hidden_configuration=logical(1);
        otherwise
            TargetCommon.ProductInfo.error('common','InputArgNInvalid','First','string new');
        end
    end
