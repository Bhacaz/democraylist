class HashService
  class << self
    # def inv_mod(num, mod)
    #     res = nil
    #     (0..mod).each do |step|
    #           k = (step * mod) + 1
    #         return k / num if k % num == 0
    #       end
    #     res
    #   end

    def hash(id)
      (id * 10_000_000 % 123_456_789).to_s(16)
    end

    def un_hash(id)
      (id.to_i(16) * 1_356_679 % 123_456_789)
    end
  end
end
