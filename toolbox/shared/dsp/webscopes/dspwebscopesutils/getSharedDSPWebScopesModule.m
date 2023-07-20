function module=getSharedDSPWebScopesModule

    module.dependsOn={};
    module.provides={'mlTimeScope','mlSpectrumAnalyzer'};
    module.modulePath.amd='dspwebscopesexports/index';
    module.bundle.location='/toolbox/shared/dsp/webscopes/dspwebscopesexports/release/bundle.mwBundle.dspwebscopesexports.js';
    module.debugDependencies.dspwebscopesexports='/toolbox/shared/dsp/webscopes/dspwebscopesexports/dspwebscopesexports';
    module.debugDependencies.dspwebscopes='/toolbox/shared/dsp/webscopes/dspwebscopesutils/js';
    module.debugDependencies.timescope='/toolbox/shared/dsp/webscopes/mltimescope/web/timescope/timescope';

    module.debugDependencies.spectrumanalyzer='/toolbox/shared/dsp/webscopes/mlspectrumanalyzer/web/spectrumanalyzer/spectrumanalyzer';


