function BatteryLoadFcn(block)














    [LASTWARNMSG,LASTID]=lastwarn;

    switch LASTID
    case 'Simulink:blocks:RefBlockUnknownParameter'

        if strfind(LASTWARNMSG,'Invalid setting in Battery block')&strfind(LASTWARNMSG,'for parameter ''BatType''')






            disp(' ');
            disp('The Battery model has been improved to better represent the battery dynamics')
            disp('during the charge and discharge processes. Hence, the model parameters and the')
            disp('meaning of the detailed parameters have changed:');
            disp(' ');
            disp('1. The ''Battery type'' parameter no longer contains the ''No (User-Defined)'' option');
            disp('   available in previous releases. It has been replaced by a new parameter named');
            disp('   ''Use parameters based on Battery type and nominal values'', that need to be unchecked');
            disp('   when you want to specify User-defined parameters.');
            disp(' ');
            disp('2. New values for detailed parameters based on the values specified in previous');
            disp('   release need to be computed for the block. For your convenience, new values have been');
            disp('   automatically updated in the mask of the block and the ''Battery type'' has been forced ');
            disp('   to ''Nickel-Metal-Hydride''. Please refer to the documentation for more details on this topic.');
            disp(' ');

            NominalVoltage=getSPSmaskvalues(block,{'NomV'});
            RatedCapacity=getSPSmaskvalues(block,{'NomQ'});


            old_FullV=getSPSmaskvalues(block,{'FullV'});
            old_Dis_rate=getSPSmaskvalues(block,{'Dis_rate'});
            old_Normal_OP=getSPSmaskvalues(block,{'Normal_OP'});
            old_expZone=getSPSmaskvalues(block,{'expZone'});


            new_MaxQ=RatedCapacity*1.05;
            new_FullV=old_FullV/100*NominalVoltage;
            new_Dis_rate=old_Dis_rate/100*RatedCapacity;
            new_Normal_OP=old_Normal_OP/100*RatedCapacity;
            new_expZone=[old_expZone(1)/100*NominalVoltage,old_expZone(2)/100*RatedCapacity];


            set_param(block,'PresetModel','no')


            set_param(block,'MaxQ',mat2str(new_MaxQ));
            set_param(block,'FullV',mat2str(new_FullV));
            set_param(block,'Dis_rate',mat2str(new_Dis_rate));
            set_param(block,'Normal_OP',mat2str(new_Normal_OP));
            set_param(block,'expZone',mat2str(new_expZone));

        end
    end