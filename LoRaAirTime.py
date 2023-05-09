from dataclasses import dataclass
import math

@dataclass
class LoRaAirTime:
    payload_len: int = None
    preamble_len: int = None
    spreading_factor: int = 7
    bandwidth: int = 125
    coding_rate: int = 5
    crc: bool = False
    explicit_header: bool = False
    low_data_rate_opt: bool = False
    payload_len_valid: bool = True
    preamble_len_valid: bool = True

    def check_payload_len(self):
        self.payload_len_valid = not (self.payload_len < 1 or self.payload_len > 255)

    def check_preamble_len(self):
        self.preamble_len_valid = not (self.preamble_len < 6 or self.preamble_len > 655365)

    @property
    def symbol_time(self):
        return f"{(2 ** self.spreading_factor / self.bandwidth):.3f}"

    @property
    def symbol_rate(self):
        return f"{(1000 / float(self.symbol_time)):.3f}"

    @property
    def throughput(self):
        if self.t_total != "-":
            return f"{((8 * self.payload_len) / float(self.t_total)) * 1000:.3f}"
        else:
            return "-"

    @property
    def n_preamble(self):
        if self.preamble_len is not None:
            return self.preamble_len + 4.25
        else:
            return "-"

    @property
    def t_preamble(self):
        if self.preamble_len is not None:
            return f"{(self.n_preamble * float(self.symbol_time)):.3f}"
        else:
            return "-"

    @property
    def n_payload(self):
        if self.payload_len is not None:
            payload_bit = 8 * self.payload_len
            payload_bit -= 4 * self.spreading_factor
            payload_bit += 8
            payload_bit += 16 if self.crc else 0
            payload_bit += 20 if self.explicit_header else 0
            payload_bit = max(payload_bit, 0)

            bits_per_symbol = self.spreading_factor - 2 if self.low_data_rate_opt else self.spreading_factor
            payload_symbol = math.ceil(payload_bit / 4 / bits_per_symbol) * self.coding_rate
            payload_symbol += 8

            return payload_symbol
        else:
            return "-"

    @property
    def t_payload(self):
        if self.payload_len is not None:
            return f"{(self.n_payload * float(self.symbol_time)):.3f}"
        else:
            return "-"

    @property
    def t_total(self):
        if self.t_preamble != "-" and self.t_payload != "-":
            return f"{(float(self.t_preamble) + float(self.t_payload)):.3f}"
        else:
            return "-"
