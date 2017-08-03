require "formula"

class Opendylan < Formula
  homepage "http://opendylan.org/"

  stable do
    url "https://web.archive.org/web/20170402235928/http://opendylan.org/downloads/opendylan/2014.1/opendylan-2014.1-x86-darwin.tar.bz2"
    sha256 "cd7b394b8943ccafd4643d157d385f002c5e695eb0601726af1064e3c15b5649"

    depends_on "bdw-gc"
  end

  head do
    url "https://github.com/dylan-lang/opendylan.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "bdw-gc" => :build
  end

  depends_on :macos => :lion
  depends_on :arch => :intel

  def install

    ENV.deparallelize

    if build.head?
      ohai "Compilation takes a long time; use `brew install -v opendylan` to see progress" unless ARGV.verbose?
      system "./autogen.sh"
      system "./configure", "--prefix=#{prefix}"
      system "make 3-stage-bootstrap"
      system "make install"
    else
      libexec.install Dir["*"]
      bin.install_symlink "#{libexec}/bin/dylan-compiler"
      bin.install_symlink "#{libexec}/bin/make-dylan-app"
      bin.install_symlink "#{libexec}/bin/dswank"
    end
  end

  test do
    app_name = "hello-world"
    system bin/"make-dylan-app", app_name
    cd app_name do
      system bin/"dylan-compiler", "-build", app_name
      assert_equal 0, $?.exitstatus
    end
    assert_equal "Hello, world!\n",
                 `#{ app_name }/_build/bin/#{ app_name }`
    assert_equal 0, $?.exitstatus
  end
end
