


function validstr=validateUMTSParameter(name,value,varargin)


    validstr=[];
    try
        if isstruct(value)
            if~isfield(value,name)
                error('umts:error','Expected structure field %s not found',name);
            end
            value=value.(name);
        end

        switch lower(name)
        case 'dlrmc'
            validstr=umtsErrorMessage('Downlink RC',value,{'RMC0kbps','RMC12.2kbps','RMC64kbps','RMC144kbps','RMC384kbps',...
            'H-Set1','H-Set2','H-Set3','H-Set4','H-Set5','H-Set6','H-Set7','H-Set8','H-Set10','H-Set12',...
            'TM1_4DPCH','TM1_8DPCH','TM1_16DPCH','TM1_32DPCH','TM1_64DPCH','TM2_3DPCH',...
            'TM3_4DPCH','TM3_8DPCH','TM3_16DPCH','TM3_32DPCH','TM4',...
            'TM5_4DPCH_4HSPDSCH','TM5_6DPCH_2HSPDSCH','TM5_14DPCH_4HSPDSCH','TM5_30DPCH_8HSPDSCH',...
            'TM6_4DPCH_4HSPDSCH','TM6_30DPCH_8HSPDSCH'});
        case 'ulrmc'
            validstr=umtsErrorMessage('Uplink RC',value,{'RMC12.2kbps','RMC64kbps','RMC144kbps','RMC384kbps',...
            'FRC1','FRC2','FRC3','FRC4','FRC5','FRC6','FRC7','FRC8'});
        case 'filtertype'
            validstr=umtsErrorMessage(name,value,{'Off','RRC'});
        case 'enable'
            validstr=umtsErrorMessage(name,value,{'Off','On'});
        case 'dlmodulation'
            validstr=umtsErrorMessage('Modulation',value,{'QPSK','16QAM','64QAM'});
        case 'ulmodulation'
            validstr=umtsErrorMessage('Modulation',value,{'BPSK','4PAM'});
        case{'power','normalizedpower','hspdschpower','hsscchpower','edpdchpower','edpcchpower'}
            umtsErrorMessage(name,value,[],{'numeric'},{'nonempty','scalar','nonnan'});
        case 'oversamplingratio'
            umtsErrorMessage(name,value,[],{'numeric'},{'>=',1,'integer','nonempty','scalar'});
        case 'primaryscramblingcode'
            umtsErrorMessage(name,value,[],{'numeric'},{'>=',0,'<=',511,'integer','nonempty','scalar'});
        case 'scramblingcode'
            umtsErrorMessage(name,value,[],{'numeric'},{'>=',0,'<=',2^24-1,'integer','nonempty','scalar'});
        case 'totframes'
            umtsErrorMessage(name,value,[],{'numeric'},{'>',0,'integer','nonempty','scalar'});
        case 'timingoffset'
            umtsErrorMessage(name,value,[],{'numeric'},{'>=',0,'<=',149,'integer','nonempty','scalar'});
        case 'nmulticodes'
            umtsErrorMessage(name,value,[],{'numeric'},{'>=',1,'<=',6,'integer','nonempty','scalar'});
        case 'activedynamicpart'
            umtsErrorMessage(name,value,[],{'numeric'},{'>=',1,'integer','nonempty','scalar'});
        case 'secondaryscramblingcode'
            umtsErrorMessage(name,value,[],{'numeric'},{'>=',0,'<=',15,'integer','nonempty','scalar'});
        case 'spreadingcode'
            umtsErrorMessage(name,value,[],{'numeric'},{'>=',0,'integer','nonempty','scalar'});
        case 'np'
            umtsErrorMessage(name,value,[18,36,72,144],{'numeric'},{'integer','nonempty','scalar'});
        case 'ueid'
            umtsErrorMessage(name,value,[],{'numeric'},{'>=',0,'<=',65535,'integer','nonempty','scalar'});
        case 'xrvsequence'
            umtsErrorMessage(name,value,[],{'numeric'},{'>=',0,'<=',7,'integer','nonempty'});
        case 'interttidistance'
            umtsErrorMessage(name,value,[],{'numeric'},{'>=',1,'<=',8,'integer','nonempty','scalar'});
        case 'virtualbuffercapacity'
            umtsErrorMessage(name,value,[],{'numeric'},{'>=',0,'integer','nonempty','scalar'});
        case 'codegroup'
            umtsErrorMessage(name,value,[],{'numeric'},{'>=',1,'<=',16,'integer','nonempty','scalar'});
        case 'codeoffset'
            umtsErrorMessage(name,value,[],{'numeric'},{'>=',0,'<=',15,'integer','nonempty','scalar'});
        case 'codecombination'
            umtsErrorMessage(name,value,2.^(2:8),{'numeric'},{'>=',4,'<=',256,'integer','nonempty'});
        case 'tti'
            umtsErrorMessage(name,value,[10,20,40,80],{'numeric'},{'integer','nonempty'});
        case{'dldchblocksize','dldchblocksetsize'}
            umtsErrorMessage(strrep(name,'DLDCH',''),value,[],{'numeric'},{'>=',0,'integer','nonempty','scalar'});
        case{'blocksize','blocksetsize'}
            umtsErrorMessage(name,value,[],{'numeric'},{'>',0,'integer','nonempty','scalar'});
        case 'transportblocksizeid'
            umtsErrorMessage(name,value,[],{'numeric'},{'>=',0,'<=',63,'integer','nonempty','scalar'});
        case 'harqack'
            umtsErrorMessage(name,value,[],{'numeric'},{'>=',0,'<=',3,'integer','nonempty'});
        case 'cqi'
            umtsErrorMessage(name,value,[],{'numeric'},{'>=',0,'<=',30,'integer','nonempty'});
        case 'rsnsequence'
            umtsErrorMessage(name,value,[],{'numeric'},{'>=',0,'<=',3,'integer','nonempty'});
        case 'ocnstype'
            validstr=umtsErrorMessage(name,value,{'RMC_16DPCH','H-Set_6DPCH','H-Set_4DPCH',...
            'TM1_4DPCH','TM1_8DPCH','TM1_16DPCH','TM1_32DPCH','TM1_64DPCH','TM2_3DPCH',...
            'TM3_4DPCH','TM3_8DPCH','TM3_16DPCH','TM3_32DPCH','TM5_4DPCH_4HSPDSCH',...
            'TM5_6DPCH_2HSPDSCH','TM5_14DPCH_4HSPDSCH','TM5_30DPCH_8HSPDSCH',...
            'TM6_4DPCH_4HSPDSCH','TM6_30DPCH_8HSPDSCH'});
        otherwise
            error('umts:error','Invalid parameter (%s) specified',name);
        end
    catch me
        newME=MException('umts:error',me.message);
        throwAsCaller(newME);
    end
end

function varaargout=umtsErrorMessage(name,value,range,varargin)
    if nargin>3

        classes=varargin{1};
        attributes=varargin{2};
    end

    if any(strcmpi(name,{'filtertype','uplink rc','downlink rc','ocnstype','enable','modulation'}))

        varaargout{1}=validatestring(value,range,'',name);
    else

        validateattributes(value,classes,attributes,'',name);
        if~isempty(range)

            for v=1:numel(value)
                if~any(value(v)==range)
                    error('umts:error','Expected %s to be one of (%s)',name,num2str(range));
                end
            end
        end
    end

end
