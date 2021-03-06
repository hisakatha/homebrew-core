class JsonC < Formula
  desc "JSON parser for C"
  homepage "https://github.com/json-c/json-c/wiki"
  url "https://github.com/json-c/json-c/archive/json-c-0.13.1-20180305.tar.gz"
  version "0.13.1"
  sha256 "5d867baeb7f540abe8f3265ac18ed7a24f91fe3c5f4fd99ac3caba0708511b90"

  bottle do
    cellar :any
    sha256 "4f51e5ad713e467d1df189c8b594c7e9ae279ed4fc2b0a8d1b328a3c258135d7" => :high_sierra
    sha256 "279d88326f2f6aff9faf0c593ae4173c058e07ba0523f73107dfcbef3b54bd45" => :sierra
    sha256 "724bffe043ecc73611fb4e7b2fcefbe35cb8b3a64aabf5cec92d43938b8e02d3" => :el_capitan
    sha256 "3094e72c250a7ddda3ff07ed6a52a198ffa809f840c2cf38a5d5105bef079285" => :x86_64_linux
  end

  head do
    url "https://github.com/json-c/json-c.git"

    depends_on "libtool" => :build
    depends_on "automake" => :build
    depends_on "autoconf" => :build
  end

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    ENV.deparallelize
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~'EOS'
      #include <stdio.h>
      #include <json-c/json.h>

      int main() {
        json_object *obj = json_object_new_object();
        json_object *value = json_object_new_string("value");
        json_object_object_add(obj, "key", value);
        printf("%s\n", json_object_to_json_string(obj));
        return 0;
      }
    EOS
    system ENV.cc, "-I#{include}", "-L#{lib}", "-ljson-c", "test.c", "-o", "test"
    assert_equal '{ "key": "value" }', shell_output("./test").chomp
  end
end
