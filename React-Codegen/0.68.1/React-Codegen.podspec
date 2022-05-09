# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

require "json"

package = JSON.parse(File.read(File.join(__dir__, "..", "..", "package.json")))
version = package['version']

source = { :git => 'https://github.com/facebook/react-native.git' }
if version == '1000.0.0'
  # This is an unpublished version, use the latest commit hash of the react-native repo, which we’re presumably in.
  source[:commit] = `git rev-parse HEAD`.strip if system("git rev-parse --git-dir > /dev/null 2>&1")
else
  source[:tag] = "v#{version}"
end

folly_compiler_flags = '-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1 -Wno-comma -Wno-shorten-64-to-32 -Wno-documentation'
folly_version = '2021.06.28.00-v2'

Pod::Spec.new do |s|
  s.name                   = "React-Codegen"
  s.version                = version
  s.summary                = "-"  # TODO
  s.homepage               = "https://reactnative.dev/"
  s.license                = package["license"]
  s.author                 = "Facebook, Inc. and its affiliates"
  s.platforms              = { :ios => "11.0" }
  s.compiler_flags         = folly_compiler_flags + ' -Wno-nullability-completeness'
  s.source                 = source
  # This podspec is used to trigger the codegen, and built files are generated in a different location.
  # We don't want this pod to actually include any files.
  s.header_dir             = "./"

  s.pod_target_xcconfig    = {
                               "HEADER_SEARCH_PATHS" => "\"$(PODS_ROOT)/boost\" \"$(PODS_ROOT)/RCT-Folly\" \"${PODS_ROOT}/Headers/Public/React-Codegen/react/renderer/components\" \"$(PODS_ROOT)/Headers/Private/React-Fabric\" \"$(PODS_ROOT)/Headers/Private/React-RCTFabric\""
                             }

  s.dependency "RCT-Folly", folly_version
  s.dependency "FBReactNativeSpec", version
  s.dependency "React-jsiexecutor", version
  s.dependency "RCTRequired", version
  s.dependency "RCTTypeSafety", version
  s.dependency "React-Core", version
  s.dependency "React-jsi", version
  s.dependency "ReactCommon/turbomodule/core", version
end
