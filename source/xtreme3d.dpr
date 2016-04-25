library xtreme3d;
uses
  Windows, Messages, Classes, Controls, StdCtrls, ExtCtrls, Dialogs, SysUtils,
  GLScene, GLObjects, GLWin32FullScreenViewer, GLMisc, GLGraph,
  GLCollision, GLTexture, OpenGL1x, VectorGeometry, Graphics,
  GLVectorFileObjects, GLWin32Viewer, GLSpaceText, GLGeomObjects, GLCadencer,
  JPeg, Tga, GLProcTextures, Spin, GLVfsPAK, GLCanvas, GLGraphics, GLPortal,
  GLHUDObjects, GLBitmapFont, GLWindowsFont, GLImposter, VectorTypes, GLUtils,
  GLPolyhedron, GLTeapot, GLzBuffer, GLFile3DS, GLFileGTS, GLFileLWO, GLFileMD2,
  GLFileMD3, Q3MD3, GLFileMS3D, GLFileMD5, GLFileNMF, GLFileNurbs, GLFileObj, GLFileOCT,
  GLFilePLY, GLFileQ3BSP, GLFileSMD, GLFileSTL, GLFileTIN, GLFileB3D,
  GLFileLOD, GLPhongShader, VectorLists, GLThorFX, GLFireFX, GLTexCombineShader,
  GLBumpShader, GLCelShader, GLContext, GLTerrainRenderer, GLHeightData,
  GLBlur, GLSLShader, GLMultiMaterialShader, GLOutlineShader, GLHiddenLineShader,
  ApplicationFileIO, GLMaterialScript, GLWaterPlane, GeometryBB, GLExplosionFx,
  GLSkyBox, GLShadowPlane, GLShadowVolume, GLSkydome, GLLensFlare, GLDCE,
  GLNavigator, GLFPSMovement;

type
   TEmpty = class(TComponent)
    private
   end;

var
  scene: TGLScene;
  matlib: TGLMaterialLibrary;
  memviewer: TGLMemoryViewer;
  cadencer: TGLCadencer;
  empty: TEmpty;

  collisionPoint: TVector;
  collisionNormal: TVector;

{$R *.res}

function LoadStringFromFile2(const fileName : String) : String;
var
   n : Cardinal;
	fs : TStream;
begin
   if FileStreamExists(fileName) then begin
   	fs:=CreateFileStream(fileName, fmOpenRead+fmShareDenyNone);
      try
         n:=fs.Size;
   	   SetLength(Result, n);
         if n>0 then
         	fs.Read(Result[1], n);
      finally
   	   fs.Free;
      end;
   end else Result:='';
end;

{$I 'engine'}
{$I 'viewer'}
{$I 'dummycube'}
{$I 'camera'}
{$I 'light'}
{$I 'fonttext'}
{$I 'sprite'}
{$I 'primitives'}
{$I 'memviewer'}
{$I 'zshadows'}
{$I 'actor'}
{$I 'freeform'}
{$I 'object'}
{$I 'polygon'}
{$I 'material'}
{$I 'shaders'}
{$I 'thorfx'}
{$I 'firefx'}
{$I 'lensflare'}
{$I 'terrain'}
{$I 'blur'}
{$I 'skybox'}
{$I 'shadowplane'}
{$I 'shadowvolume'}
{$I 'skydome'}
{$I 'water'}
{$I 'navigator'}
{$I 'dce'}
{$I 'text'}

function FpsManagerCreate: real; stdcall;
var
  FPSManager: TGLFPSMovementManager;
begin
  FPSManager := TGLFPSMovementManager.Create(scene);
  Result := Integer(FPSManager);
end;

function FpsManagerSetNavigator(man, nav: real): real; stdcall;
begin
  TGLFPSMovementManager(trunc64(man)).Navigator := TGLNavigator(trunc64(nav));
  Result := 1;
end;

function FpsManagerSetMovementScale(man, scale: real): real; stdcall;
begin
  TGLFPSMovementManager(trunc64(man)).MovementScale := scale;
  Result := 1;
end;

function FpsManagerAddMap(man, ffm: real): real; stdcall;
var
  freeform: TGLFreeform;
begin
  freeform := TGLFreeform(trunc64(ffm));
  TGLFPSMovementManager(trunc64(man)).Maps.addMap(freeform);
  Result := 1;
end;

function FpsManagerRemoveMap(man, ffm: real): real; stdcall;
begin
  TGLFPSMovementManager(trunc64(man)).Maps.findMap(TGLFreeform(trunc64(ffm))).Free;
  Result := 1;
end;

function FpsManagerMapSetCollisionGroup(man, ffm, group: real): real; stdcall;
begin
  TGLFPSMovementManager(trunc64(man)).Maps.findMap(TGLFreeform(trunc64(ffm))).CollisionGroup := trunc64(group);
  Result := 1;
end;

function FpsSetManager(obj, man: real): real; stdcall;
var
  ob: TGLBaseSceneObject;
  fps: TGLBFPSMovement;
begin
  ob := TGLBaseSceneObject(trunc64(obj));
  fps := GetOrCreateFPSMovement(ob);
  fps.Manager := TGLFPSMovementManager(trunc64(man));
  Result := 1;
end;

function FpsSetCollisionGroup(obj, group: real): real; stdcall;
var
  ob: TGLBaseSceneObject;
  fps: TGLBFPSMovement;
begin
  ob := TGLBaseSceneObject(trunc64(obj));
  fps := GetOrCreateFPSMovement(ob);
  fps.CollisionGroup := trunc64(group);
  Result := 1;
end;

function FpsSetSphereRadius(obj, radius: real): real; stdcall;
var
  ob: TGLBaseSceneObject;
  fps: TGLBFPSMovement;
begin
  ob := TGLBaseSceneObject(trunc64(obj));
  fps := GetOrCreateFPSMovement(ob);
  fps.SphereRadius := radius;
  Result := 1;
end;

function FpsSetGravity(obj, mode: real): real; stdcall;
var
  ob: TGLBaseSceneObject;
  fps: TGLBFPSMovement;
begin
  ob := TGLBaseSceneObject(trunc64(obj));
  fps := GetOrCreateFPSMovement(ob);
  fps.GravityEnabled := Boolean(trunc64(mode));
  Result := 1;
end;

function FpsMove(obj, spd: real): real; stdcall;
var
  ob: TGLBaseSceneObject;
  fps: TGLBFPSMovement;
begin
  ob := TGLBaseSceneObject(trunc64(obj));
  fps := GetOrCreateFPSMovement(ob);
  fps.MoveForward(spd);
  Result := 1;
end;

function FpsStrafe(obj, spd: real): real; stdcall;
var
  ob: TGLBaseSceneObject;
  fps: TGLBFPSMovement;
begin
  ob := TGLBaseSceneObject(trunc64(obj));
  fps := GetOrCreateFPSMovement(ob);
  fps.StrafeHorizontal(spd);
  Result := 1;
end;

function FpsLift(obj, spd: real): real; stdcall;
var
  ob: TGLBaseSceneObject;
  fps: TGLBFPSMovement;
begin
  ob := TGLBaseSceneObject(trunc64(obj));
  fps := GetOrCreateFPSMovement(ob);
  fps.StrafeVertical(spd);
  Result := 1;
end;

function FpsGetVelocity(obj, ind: real): real; stdcall;
var
  ob: TGLBaseSceneObject;
  fps: TGLBFPSMovement;
begin
  ob := TGLBaseSceneObject(trunc64(obj));
  fps := GetOrCreateFPSMovement(ob);
  Result := fps.velocity[trunc64(ind)];
end;

// TODO:
// FpsCountCollisions
// FpsClearCollisions
// FpsGetCollisionPosition
// FpsGetCollisionNormal
// FpsGetCollidedObject

exports

//Engine
EngineCreate, EngineDestroy, EngineSetObjectsSorting, EngineSetCulling,
SetPakArchive,
Update, TrisRendered,
//Viewer
ViewerCreate, ViewerSetCamera, ViewerEnableVSync, ViewerRenderToFile,
ViewerRender,
ViewerResize, ViewerSetVisible, ViewerGetPixelColor, ViewerGetPixelDepth,
ViewerSetLighting, ViewerSetBackgroundColor, ViewerSetAmbientColor, ViewerEnableFog,
ViewerSetFogColor, ViewerSetFogDistance, ViewerScreenToWorld, ViewerWorldToScreen,
ViewerCopyToTexture, ViewerGetFramesPerSecond, ViewerGetPickedObject,
ViewerScreenToVector, ViewerVectorToScreen, ViewerPixelToDistance, ViewerGetPickedObjectsList,
ViewerSetAntiAliasing,
ViewerGetVBOSupported, ViewerGetGLSLSupported,
//Dummycube
DummycubeCreate, DummycubeAmalgamate, DummycubeSetCameraMode, DummycubeSetVisible,
DummycubeSetEdgeColor, DummycubeSetCubeSize,
//Camera
CameraCreate, CameraSetStyle, CameraSetFocal, CameraSetSceneScale,
CameraScaleScene, CameraSetViewDepth, CameraSetTargetObject,
CameraMoveAroundTarget, CameraSetDistanceToTarget, CameraGetDistanceToTarget,
CameraCopyToTexture, CameraGetNearPlane, CameraSetNearPlaneBias,
CameraAbsoluteVectorToTarget, CameraAbsoluteRightVectorToTarget, CameraAbsoluteUpVectorToTarget,
CameraZoomAll, CameraScreenDeltaToVector, CameraScreenDeltaToVectorXY, CameraScreenDeltaToVectorXZ,
CameraScreenDeltaToVectorYZ, CameraAbsoluteEyeSpaceVector, CameraSetAutoLeveling,
CameraMoveInEyeSpace, CameraMoveTargetInEyeSpace, CameraPointInFront, CameraGetFieldOfView,
//Light
LightCreate, LightSetAmbientColor, LightSetDiffuseColor, LightSetSpecularColor,
LightSetAttenuation, LightSetShining, LightSetSpotCutoff, LightSetSpotExponent,
LightSetSpotDirection, LightSetStyle,
//Font & Text
BmpFontCreate, BmpFontLoad, WindowsBitmapfontCreate, HUDTextCreate, FlatTextCreate,
HUDTextSetRotation, SpaceTextCreate, SpaceTextSetExtrusion, HUDTextSetFont,
FlatTextSetFont, SpaceTextSetFont, HUDTextSetColor, FlatTextSetColor, HUDTextSetText,
FlatTextSetText, SpaceTextSetText,
//Sprite
HUDSpriteCreate, SpriteCreate, SpriteSetSize, SpriteScale, SpriteSetRotation,
SpriteRotate, SpriteMirror, SpriteNoZWrite,    
//Primitives
CubeCreate, CubeSetNormalDirection, PlaneCreate, SphereCreate, SphereSetAngleLimits,
CylinderCreate, ConeCreate, AnnulusCreate, TorusCreate, DiskCreate, FrustrumCreate,
DodecahedronCreate, IcosahedronCreate, TeapotCreate,
//Memory Viewer
MemoryViewerCreate, MemoryViewerSetCamera, MemoryViewerRender,
//ZShadows
ZShadowsCreate,
ZShadowsSetFrustShadow, ZShadowsSetSkyShadow, ZShadowsSetColor, ZShadowsCast,
ZShadowsSetSoft, ZShadowsSetTolerance, ZShadowsSetDepthFade,
//Actor
ActorCreate, ActorCopy, ActorSetAnimationRange, ActorGetCurrentFrame, ActorSwitchToAnimation,
ActorSwitchToAnimationName, ActorSynchronize, ActorSetInterval, ActorSetAnimationMode,
ActorSetFrameInterpolation, ActorAddObject, ActorGetCurrentAnimation, ActorGetFrameCount,
ActorGetBoneCount, ActorGetBoneByName, ActorGetBoneRotation, ActorGetBonePosition,
ActorBoneExportMatrix, ActorMakeSkeletalTranslationStatic, ActorMakeSkeletalRotationDelta, 
ActorShowSkeleton, 
AnimationBlenderCreate, AnimationBlenderSetActor, AnimationBlenderSetAnimation,
AnimationBlenderSetRatio,
ActorLoadQ3TagList, ActorLoadQ3Animations, ActorQ3TagExportMatrix,
ActorMeshObjectsCount, ActorFaceGroupsCount, ActorFaceGroupGetMaterialName,
ActorFaceGroupSetMaterial,
//Freeform
FreeformCreate, FreeformMeshObjectsCount, FreeformMeshSetVisible,
FreeformMeshSetSecondCoords, FreeformMeshTriangleCount,  
FreeformFaceGroupsCount, FreeformFaceGroupTriangleCount,
FreeformSetLightmapsFromFreeform,
FreeformCreateExplosionFX, FreeformExplosionFXReset,
FreeformExplosionFXEnable, FreeformExplosionFXSetSpeed,
//Terrain
BmpHDSCreate, BmpHDSSetInfiniteWarp, BmpHDSInvert,
TerrainCreate, TerrainSetHeightData, TerrainSetTileSize, TerrainSetTilesPerTexture,
TerrainSetQualityDistance, TerrainSetQualityStyle, TerrainSetMaxCLodTriangles,
TerrainSetCLodPrecision, TerrainSetOcclusionFrameSkip, TerrainSetOcclusionTesselate,
TerrainGetHeightAtObjectPosition, TerrainGetLastTriCount,
//Object
ObjectHide, ObjectShow, ObjectIsVisible,
ObjectCopy, ObjectDestroy, ObjectDestroyChildren,
ObjectSetPosition, ObjectGetPosition, ObjectGetAbsolutePosition,
ObjectSetPositionOfObject, ObjectAlignWithObject,
ObjectSetPositionX, ObjectSetPositionY, ObjectSetPositionZ,
ObjectGetPositionX, ObjectGetPositionY, ObjectGetPositionZ,
ObjectSetAbsolutePosition,
ObjectSetDirection, ObjectGetDirection,
ObjectSetAbsoluteDirection, ObjectGetAbsoluteDirection,
ObjectGetPitch, ObjectGetTurn, ObjectGetRoll, ObjectSetRotation,
ObjectMove, ObjectLift, ObjectStrafe, ObjectTranslate, ObjectRotate,
ObjectScale, ObjectSetScale,
ObjectSetUpVector, ObjectPointToObject, 
ObjectShowAxes,
ObjectGetGroundHeight, ObjectSceneRaycast, ObjectRaycast,
ObjectGetCollisionPosition, ObjectGetCollisionNormal, 
ObjectSetMaterial,
ObjectGetDistance,
ObjectCheckCubeVsCube, ObjectCheckSphereVsSphere, ObjectCheckSphereVsCube,
ObjectIsPointInObject,
ObjectSetCulling,
ObjectSetName, ObjectGetName, ObjectGetClassName,
ObjectSetTag, ObjectGetTag,
ObjectGetParent, ObjectGetChildCound, ObjectGetChild, ObjectGetIndex, ObjectFindChild,
ObjectGetBoundingSphereRadius,
ObjectGetAbsoluteUp, ObjectSetAbsoluteUp, ObjectGetAbsoluteRight,
ObjectGetAbsoluteXVector, ObjectGetAbsoluteYVector, ObjectGetAbsoluteZVector,
ObjectGetRight,
ObjectMoveChildUp, ObjectMoveChildDown,
ObjectSetParent, ObjectRemoveChild,
ObjectMoveObjectAround,
ObjectPitch, ObjectTurn, ObjectRoll,
ObjectGetUp,
ObjectRotateAbsolute, ObjectRotateAbsoluteVector,
ObjectSetMatrixColumn,
ObjectExportMatrix, ObjectExportAbsoluteMatrix,
//Polygon
PolygonCreate, PolygonAddVertex, PolygonSetVertexPosition, PolygonDeleteVertex,
//Material
MaterialLibraryCreate, MaterialLibraryActivate, MaterialLibrarySetTexturePaths,
MaterialLibraryClear, MaterialLibraryDeleteUnused,
MaterialLibraryHasMaterial, MaterialLibraryLoadScript, 
MaterialCreate,
MaterialAddCubeMap, MaterialCubeMapLoadImage, MaterialCubeMapGenerate, MaterialCubeMapFromScene,
MaterialSaveTexture, MaterialSetBlendingMode, MaterialSetOptions,
MaterialSetTextureMappingMode, MaterialSetTextureMode,
MaterialSetShader, MaterialSetSecondTexture,
MaterialSetDiffuseColor, MaterialSetAmbientColor, MaterialSetSpecularColor, MaterialSetEmissionColor,
MaterialSetShininess,
MaterialSetPolygonMode, MaterialSetTextureImageAlpha,
MaterialSetTextureScale, MaterialSetTextureOffset,
MaterialSetTextureFilter, MaterialEnableTexture,
MaterialGetCount, MaterialGetName,
MaterialSetFaceCulling, MaterialSetSecondTexture,
MaterialSetTextureFormat, MaterialSetTextureCompression,
MaterialTextureRequiredMemory, MaterialSetFilteringQuality,
MaterialAddTextureEx, MaterialTextureExClear, MaterialTextureExDelete,
MaterialNoiseCreate, MaterialNoiseAnimate, MaterialNoiseSetDimensions,
MaterialNoiseSetMinCut, MaterialNoiseSetSharpness, MaterialNoiseSetSeamless,
MaterialNoiseRandomSeed,
//Shaders
ShaderEnable, 
BumpShaderCreate, BumpShaderSetMethod, BumpShaderSetSpecularMode,
BumpShaderSetSpace, BumpShaderSetOptions, BumpShaderSetParallaxOffset,
CelShaderCreate, CelShaderSetLineColor, CelShaderSetLineWidth, CelShaderSetOptions,
MultiMaterialShaderCreate,
HiddenLineShaderCreate, HiddenLineShaderSetLineSmooth, HiddenLineShaderSetSolid,
HiddenLineShaderSetSurfaceLit, HiddenLineShaderSetFrontLine, HiddenLineShaderSetBackLine,
OutlineShaderCreate, OutlineShaderSetLineColor, OutlineShaderSetLineWidth,
TexCombineShaderCreate, TexCombineShaderAddCombiner,
TexCombineShaderMaterial3, TexCombineShaderMaterial4,
PhongShaderCreate,
GLSLShaderCreate, GLSLShaderCreateParameter,
GLSLShaderSetParameter1i, GLSLShaderSetParameter1f, GLSLShaderSetParameter2f,
GLSLShaderSetParameter3f, GLSLShaderSetParameter4f, GLSLShaderSetParameterTexture,
GLSLShaderSetParameterMatrix, GLSLShaderSetParameterInvMatrix,
//ThorFX
ThorFXManagerCreate, ThorFXSetColor, ThorFXEnableCore, ThorFXEnableGlow,
ThorFXSetMaxParticles, ThorFXSetGlowSize, ThorFXSetVibrate, ThorFXSetWildness,
ThorFXSetTarget, ThorFXCreate,
// FireFX
FireFXManagerCreate, FireFXCreate,
FireFXSetColor, FireFXSetMaxParticles, FireFXSetParticleSize,
FireFXSetDensity, FireFXSetEvaporation, FireFXSetCrown,
FireFXSetLife, FireFXSetBurst, FireFXSetRadius, FireFXExplosion,
//Lensflare
LensflareCreate, LensflareSetSize, LensflareSetSeed, LensflareSetSqueeze,
LensflareSetStreaks, LensflareSetStreakWidth, LensflareSetSecs,
LensflareSetResolution, LensflareSetElements, LensflareSetGradients,
//Skydome
SkydomeCreate, SkydomeSetOptions, SkydomeSetDeepColor, SkydomeSetHazeColor,
SkydomeSetNightColor, SkydomeSetSkyColor, SkydomeSetSunDawnColor, SkydomeSetSunZenithColor,
SkydomeSetSunElevation, SkydomeSetTurbidity,
SkydomeAddRandomStars, SkydomeAddStar, SkydomeClearStars, SkydomeTwinkleStars, 
//Water
WaterCreate, WaterCreateRandomRipple,
WaterCreateRippleAtGridPosition, WaterCreateRippleAtWorldPosition,
WaterCreateRippleAtObjectPosition,
WaterSetMask, WaterSetActive, WaterReset,
WaterSetRainTimeInterval, WaterSetRainForce,
WaterSetViscosity, WaterSetElastic, WaterSetResolution,
WaterSetLinearWaveHeight, WaterSetLinearWaveFrequency,
//Blur
BlurCreate, BlurSetPreset, BlurSetOptions, BlurSetResolution,
BlurSetColor, BlurSetBlendingMode,
//Skybox
SkyboxCreate, SkyboxSetMaterial, SkyboxSetClouds, SkyboxSetStyle,
//Shadowplane
ShadowplaneCreate, ShadowplaneSetLight, ShadowplaneSetObject, ShadowplaneSetOptions,
//Shadowvolume
ShadowvolumeCreate, ShadowvolumeSetActive,
ShadowvolumeAddLight, ShadowvolumeRemoveLight,
ShadowvolumeAddOccluder, ShadowvolumeRemoveOccluder,
ShadowvolumeSetDarkeningColor, ShadowvolumeSetMode, ShadowvolumeSetOptions,
//Navigator
NavigatorCreate, NavigatorSetObject, NavigatorSetUseVirtualUp, NavigatorSetVirtualUp,  
NavigatorTurnHorizontal, NavigatorTurnVertical, NavigatorMoveForward,
NavigatorStrafeHorizontal, NavigatorStrafeVertical, NavigatorStraighten,
NavigatorFlyForward, NavigatorMoveUpWhenMovingForward, NavigatorInvertHorizontalWhenUpsideDown,
NavigatorSetAngleLock, NavigatorSetAngles,
//DCE
DceManagerCreate, DceManagerStep, DceManagerSetGravity, DceManagerSetWorldDirection,
DceManagerSetWorldScale, DceManagerSetMovementScale,
DceManagerSetLayers, DceManagerSetManualStep,
DceDynamicSetManager, DceDynamicSetActive, DceDynamicIsActive,
DceDynamicSetUseGravity, DceDynamicSetLayer, DceDynamicGetLayer,
DceDynamicSetSolid, DceDynamicSetFriction, DceDynamicSetBounce,
DceDynamicSetSize, DceDynamicSetSlideOrBounce,
DceDynamicApplyAcceleration, DceDynamicApplyAbsAcceleration,
DceDynamicStopAcceleration, DceDynamicStopAbsAcceleration,
DceDynamicJump, DceDynamicMove, DceDynamicMoveTo, DceDynamicSetSpeed,
DceDynamicInGround, DceDynamicSetMaxRecursionDepth,
DceStaticSetManager, DceStaticSetActive, DceStaticSetShape, DceStaticSetLayer,
DceStaticSetSize, DceStaticSetSolid, DceStaticSetFriction, DceStaticSetBounceFactor,
DceDynamicGetVelocity,
//FPSManager
FpsManagerCreate, FpsManagerSetNavigator, FpsManagerSetMovementScale,
FpsManagerAddMap, FpsManagerRemoveMap, FpsManagerMapSetCollisionGroup,
FpsSetManager, FpsSetCollisionGroup, FpsSetSphereRadius, FpsSetGravity,
FpsMove, FpsStrafe, FpsLift, FpsGetVelocity,
//Text
TextRead;

begin
end.
