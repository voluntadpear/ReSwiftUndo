Pod::Spec.new do |spec|
  spec.name = "ReSwiftUndo"
  spec.version = "0.1.0"
  spec.summary = "Sample framework from blog post, not for real world use."
  spec.homepage = "https://github.com/voluntadpear/ReSwiftUndo"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Your Name" => 'your-email@example.com' }
  spec.social_media_url = "http://twitter.com/thoughtbot"

  spec.platform = :ios, "9.1"
  spec.requires_arc = true
  spec.source = { git: "https://github.com/voluntadpear/ReSwiftUndo.git", tag: "v#{spec.version}", submodules: true }
  spec.source_files = "ReSwiftUndo/**/*.{h,swift}"
  spec.dependency 'ReSwift', '~> 3.0'
end
