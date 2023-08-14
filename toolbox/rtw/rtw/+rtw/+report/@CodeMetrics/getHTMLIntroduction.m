function introduction=getHTMLIntroduction(obj)




    rtwcm=obj.Data;
    intro_msg=sprintf(obj.msgs.intro_msg,rtwcm.getBasicTypeString);
    imgBytes='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAADhElEQVQ4T2WTe0yTBxTFz/fRIn2AqS1LC4gplIcFYYkTxjTpiMQRJo50KhYmexkkIWwsTMtIFCWMAZuFoc7nXNiWbLhibdMtA4oL7hFskI7KoxOGLbRCulEeK5Ty9WsXMRDn7p8355zc3PwOgaenuI8pkW7MO7RtY9GuaJbEF4DfMO62tA+4WieVSbqn5cSTi6jGUdnp3YK6otSwDEYQSbioAB4JeEwCbq8vcM00a6i/7aqaUib2rfnWA5LPjR/WFkRejOEFsz8d9UE37oGXpkHSfoTSfsjj2XhbyoZpyuPKuzzy+sSp7fpHIasBz9SNZPSWxHSFhQZzXjYsYnZuGY3Pc5AVtQEEAvjJ6oGy8y9s3hSCm/lCmBxLrqzSK5mLunIzgVMBsiV71lCWzsuUdbhx1+rG4CE+ojlBqNRPgiQInM6JhGOeQkLjKOTPhaPtoBAV6kG96npNHiFssGSOlscZ9HaKVKj/xr4YEtr9IpzpcuB9zTSw4kfbUTEO7hBgZ/09/Gal0XMsHtGbyBXpca2MeK3dfukreWSxXDcDjdmNcCYFRSwTavM8Hs74IYsNwY2jEix5KGw/2Q/nAgOlOSKcK4hGuqqvgWi+47pVtoOXmXbJjrt2D+CngYVlgKKRFcdCe2k8Vrw0Xm0w4baNApgbkJMchu+PJaLgG4uGqP3F2VG1M3zPC83j6P1zEQjCqpnj88JckwIBJwh7ThpxZ8IH8EMBD41XUrm4WSHFgdYhNfFSq/XDH4u2VB1pteFzgxPgkAAVQDjLj5GPnsXX3ZMov/YAEPEAkgRcS6iWR6A6X4yEyh9OENwTvyfdq9hqnHZ62Rm1w0Aw4/EVHi8U29iw2BdhmiEAbsjqQ9nLbgydSYdjhZ7bVViXvcpBic5x5UJuxBHltzY0ahwAi4FYAQMDtakwjs1jd/0wAkwmMLOAprckKM8TI/fjzi/1LVdLHpN4vD/iuzfjevYnciXV1634RGeHj6Jw/g0xzA8WcFYzAb6AhWpFDMr2idHSM2F5t7KpEL3N/esoc9/pSP6sUNp2OC1KOjblQdvPDzF43wWCCCBtKx/5skiI+CFQ3bIOKeu+eM/XXdO1jvJaMdjF7aLsFOEHZXtTFC9u4QrW9jSArvvz003qX7Wd2u4LMKoG/lem/9Q0V5WUtJknSxCyRQE/yOGpf5x/jNmMsM31Y+ys90ntv6Qkblq/pPiXAAAAAElFTkSuQmCC';
    aImg=ModelAdvisor.Element;
    aImg.setTag('img');
    aImg.setAttribute('src',imgBytes);
    aImg.setAttribute('title',obj.msgs.codegen_adv_help_msg);
    aImg.setAttribute('style','border:none;cursor:pointer;max-width:100%;');
    aImg.setAttribute('alt','help.png');
    aLink=ModelAdvisor.Element;
    aLink.setContent(aImg.emitHTML);
    aLink.setTag('a');
    aLink.setAttribute('name','MATLAB_link');
    aLink.setAttribute('style','text-decoration: none');

    if Simulink.report.ReportInfo.featureReportV2


        aLink.setAttribute('href','javascript: void(0)');
        aLink.setAttribute('onclick','postParentWindowMessage({message:''legacyMCall'', expr:''helpview(fullfile(docroot, \''toolbox\'', \''ecoder\'', \''helptargets.map\''), \''code_gen_advisor\'')''})');
    else

        aLink.setAttribute('href','matlab:helpview([docroot ''/toolbox/ecoder/helptargets.map''], ''code_gen_advisor'')');
    end

    code_gen_adv_msg=sprintf(obj.msgs.openCodeGenAdvHelp_msg,aLink.emitHTML);
    intro_elem=ModelAdvisor.Element;
    intro_elem.setTag('p');
    intro_elem.setContent([intro_msg,' ',obj.msgs.disclaimer_msg,' ',code_gen_adv_msg]);
    introduction=intro_elem.emitHTML();
    if~isempty(rtwcm.nonintegratedChildModels)
        introduction=[introduction,'<p><b>',obj.msgs.missChildModel_msg,'</b></p>'];
    end
    if~isempty(rtwcm.protectedChildModels)

        mdlList='';
        if length(rtwcm.protectedChildModels)>=1
            mdlList=rtwcm.protectedChildModels{1};
            for it=2:length(rtwcm.protectedChildModels)
                mdlList=[mdlList,', ',rtwcm.protectedChildModels{it}];%#ok<AGROW>
            end
        end

        introduction=[introduction,'<p><b>',obj.getMessage('MissProtectedModel',obj.ModelName),' ',mdlList,'.</b></p>'];
    end

    if Simulink.report.ReportInfo.featureReportV2
        postFcnDef=['<script>',coder.report.internal.getPostParentWindowMessageDef,'</script>'];

        introduction=[postFcnDef,introduction];
    end

end
