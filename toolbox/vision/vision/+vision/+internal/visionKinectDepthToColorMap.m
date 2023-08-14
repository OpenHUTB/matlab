
function alignmentMap=visionKinectDepthToColorMap(depthDevice,depthImage)

    alignmentMap=imaq.internal.KinectDepth2ColorMap(depthDevice,depthImage);