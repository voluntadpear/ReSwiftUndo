Pod::Spec.new do |spec|
  spec.name = "ReSwiftUndo"
  spec.version = "0.1.3-alpha.1"
  spec.summary = "Swift implementation of redux-undo for use with ReSwift"
  spec.homepage = "https://github.com/voluntadpear/ReSwiftUndo"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.author = { "Guillermo Peralta Scura" => 'gperaltascura@gmail.com' }
  spec.platform = :ios, "9.1"
  spec.requires_arc = true
  spec.source = { git: "https://github.com/voluntadpear/ReSwiftUndo.git", tag: "v#{spec.version}"}
  spec.source_files = "ReSwiftUndo/**/*.{h,swift}"
  spec.dependency 'ReSwift', '~> 4.0'
end
