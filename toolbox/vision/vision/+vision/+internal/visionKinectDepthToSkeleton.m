
function xyzPoints=visionKinectDepthToSkeleton(depthDevice,depthImage)
    xyzPoints=imaq.internal.KinectDepth2Skeleton(depthDevice,depthImage);