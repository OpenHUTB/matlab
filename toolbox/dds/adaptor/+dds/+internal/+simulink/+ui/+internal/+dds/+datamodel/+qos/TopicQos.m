classdef TopicQos<dds.internal.simulink.ui.internal.dds.datamodel.qos.Qos



    properties(Access=private)
    end

    methods
        function this=TopicQos(mdl,tree,node)
            this@dds.internal.simulink.ui.internal.dds.datamodel.qos.Qos(mdl,tree,node);
        end
    end


    methods(Static,Access=public)

        function topicQos=getQos(tree)
            topicQos=dds.internal.simulink.ui.internal.dds.datamodel.qos.Qos.getQos(tree,'TopicQoses');
        end

        function topicQosObj=getQosObj(tree,qosName)
            topicQosObj=dds.internal.simulink.ui.internal.dds.datamodel.qos.Qos.getQosObj(tree,'TopicQoses',qosName);
        end

    end



    methods(Access=private)


    end
end
