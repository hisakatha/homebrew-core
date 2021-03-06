class MongoCDriver < Formula
  desc "C driver for MongoDB"
  homepage "https://github.com/mongodb/mongo-c-driver"
  url "https://github.com/mongodb/mongo-c-driver/releases/download/1.10.3/mongo-c-driver-1.10.3.tar.gz"
  sha256 "0b6d5888a3a87b75d2aeabfb6ae7ac09196d06debf7f2cfc2781807a85c2aaa8"
  head "https://github.com/mongodb/mongo-c-driver.git"

  bottle do
    cellar :any
    sha256 "2b69fe395307b7be973e72cf34a668c00f8b8e19b996ce31b934fdd67cbf0225" => :high_sierra
    sha256 "01214580f9e4739bb14d3810e647c5f0b61eb3596332e3e045b94c173af0ce2c" => :sierra
    sha256 "fd2cef1095217bee49c39ade25a2aeebb0f1791bbcef3aee07d3f9b40b4527c1" => :el_capitan
    sha256 "dd0ddaf8feecf25b7cbe3524e82f7d036e5f45f61def0da8ec60282d55a7fb8a" => :x86_64_linux
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "sphinx-doc" => :build
  unless OS.mac?
    depends_on "openssl"
    depends_on "zlib"
  end

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
    (pkgshare/"libbson").install "src/libbson/examples"
    (pkgshare/"libmongoc").install "src/libmongoc/examples"
  end

  test do
    system ENV.cc, "-o", "test", pkgshare/"libbson/examples/json-to-bson.c",
      "-I#{include}/libbson-1.0", "-L#{lib}", "-lbson-1.0"
    (testpath/"test.json").write('{"name": "test"}')
    assert_match "\u0000test\u0000", shell_output("./test test.json")

    system ENV.cc, "-o", "test", pkgshare/"libmongoc/examples/mongoc-ping.c",
      "-I#{include}/libmongoc-1.0", "-I#{include}/libbson-1.0",
      "-L#{lib}", "-lmongoc-1.0", "-lbson-1.0"
    assert_match "No suitable servers", shell_output("./test mongodb://0.0.0.0 2>&1", 3)
  end
end
